#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Web Server Setup ==="

# --- FIX 1: dnf background timer race ---
# AL2023's dnf-makecache.timer can run concurrently with our own dnf
# install and delete/replace cached .rpm files mid-transaction:
#   [Errno 2] No such file or directory: '.../packages/foo.rpm'
# dnf does not always exit non-zero when this happens (set -e doesn't
# catch it), so the script silently continues without the package
# installed and everything downstream fails with "command not found".
systemctl stop dnf-makecache.timer 2>/dev/null || true
systemctl disable dnf-makecache.timer 2>/dev/null || true

install_with_retry() {
  local max_attempts=3
  local attempt=1
  while [ "$attempt" -le "$max_attempts" ]; do
    echo "dnf install attempt $attempt/$max_attempts: $*"
    if dnf install -y --refresh "$@"; then
      return 0
    fi
    echo "dnf install attempt $attempt failed, cleaning cache and retrying..."
    dnf clean packages 2>/dev/null || true
    attempt=$((attempt + 1))
    sleep 5
  done
  echo "FATAL: dnf install failed after $max_attempts attempts: $*"
  return 1
}

# --- FIX 2: dnf update <pkg> does NOT install new packages ---
# `dnf update -y nodejs npm git` only upgrades packages that are
# ALREADY installed. On a bare instance where none of these exist yet,
# it fails with "No match for argument: nodejs" and does nothing.
# Must use `dnf install`, not `dnf update`, to install NEW packages.
install_with_retry nodejs npm git socat

# --- FIX 3: hard verification gates ---
# Never trust that a step "probably" worked — verify explicitly and
# abort loudly if not, instead of silently limping on with missing
# binaries (this is what caused hours of debugging in the 2026-07-30
# session: dnf failed silently, pm2 was never installed, curl to
# localhost:3000 returned "Connection refused" with zero clue why).
for bin in node npm git socat; do
  command -v "$bin" >/dev/null 2>&1 || { echo "FATAL: $bin not installed, aborting"; exit 1; }
done

npm install -g pm2
command -v pm2 >/dev/null 2>&1 || { echo "FATAL: pm2 not installed, aborting"; exit 1; }

mkdir -p /opt/crazy-clothes
cd /opt/crazy-clothes

# --- FIX 4: actually clone the repo ---
# The original script left the git clone COMMENTED OUT with a note
# "you'll deploy via other means" and then ran `npm install` against
# an EMPTY directory. Public repo, no deploy key needed:
git clone https://github.com/jossjic/crazy-clothes.git .

# --- FIX 5: install runtime deps only, but NOT with --production ---
# for the OLD approach of building locally. See FIX 7 below — this repo
# no longer builds locally at all, only installs RUNTIME deps for
# `next start` (tailwind/postcss/autoprefixer are NOT needed at runtime,
# only at build time, which now happens in CI — see part 4 of this doc).
npm install --omit=dev
[ -d node_modules/next ] || { echo "FATAL: npm install did not produce node_modules/next, aborting"; exit 1; }

cat > .env.local <<EOF
DB_HOST=${db_host}
DB_PORT=3306
DB_USER=root
DB_PASSWORD=CrazyClothes2026SecurePass
DB_NAME=cc
NODE_ENV=production
EOF

# --- FIX 6: "build once, deploy many" — download prebuilt .next, never
# build locally per-instance ---
# Building independently on every ASG instance produces a DIFFERENT
# non-deterministic Next.js build ID / chunk hash on each instance
# (Next.js build IDs are not reproducible across independent builds of
# identical source). With 2+ instances behind an ALB without sticky
# sessions, the browser gets HTML from instance A referencing a chunk
# hash that only exists on instance A — instance B returns 404 for
# that chunk → ChunkLoadError in the browser. This is NOT an
# occasional flake, it WILL happen on every multi-instance deploy that
# builds locally. The .next artifact MUST be built exactly once
# (ideally in CI, see part 4) and the identical artifact deployed to
# every instance.
aws s3 cp s3://crazy-clothes-deploy-660759882203/next-build.tar.gz /tmp/next-build.tar.gz
rm -rf /opt/crazy-clothes/.next
tar -xzf /tmp/next-build.tar.gz -C /opt/crazy-clothes

pm2 start npm --name "crazy-clothes" -- start
pm2 startup systemd -u root --hp /root
pm2 save
systemctl enable pm2-root

# --- FIX 7: port mismatch shim ---
# package.json's "start" script runs `next start -p 3939`, but the ALB
# target group / security group (see main.tf) expect port 3000.
# socat forwards 3000 -> 3939 as a stopgap. REAL fix (recommended,
# not yet applied to source): either change package.json's start
# script to `next start -p 3000` (drop the custom port entirely), OR
# change the target group / security group in main.tf to port 3939.
# Whichever you pick, remove this socat shim afterward — it's a
# workaround, not the correct fix.
pkill socat 2>/dev/null || true
nohup socat TCP-LISTEN:3000,fork,reuseaddr TCP:127.0.0.1:3939 > /var/log/socat.log 2>&1 &
disown

echo "=== Web Server Setup Complete ==="
echo "App running on port 3939, forwarded from 3000 via socat"
echo "Database host: ${db_host}"
