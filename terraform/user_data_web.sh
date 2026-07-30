#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Web Server Setup ==="

# Update system
dnf update -y

# Install Node.js 20
dnf install -y nodejs npm git

# Install PM2 globally (process manager for Node.js)
npm install -g pm2

# Create app directory
mkdir -p /opt/crazy-clothes
cd /opt/crazy-clothes

# Clone repository (you'll need to configure GitHub access or use S3)
# Option 1: Clone from GitHub (needs deploy key)
# git clone https://github.com/jossjic/crazy-clothes.git .

# Option 2: Download from S3
# aws s3 sync s3://your-bucket/app/ /opt/crazy-clothes/

# For now, we'll assume you'll deploy via other means
# Create a placeholder that will be replaced by actual deployment

# Install dependencies
npm install --production

# Create .env.local with database connection
cat > .env.local <<EOF
DB_HOST=${db_host}
DB_PORT=3306
DB_USER=ccuser
DB_PASSWORD=CrazyClothes2026User
DB_NAME=cc
NODE_ENV=production
EOF

# Build Next.js app
npm run build

# Start app with PM2
pm2 start npm --name "crazy-clothes" -- start
pm2 startup systemd -u root --hp /root
pm2 save

# Configure PM2 to start on boot
systemctl enable pm2-root

echo "=== Web Server Setup Complete ==="
echo "App running on port 3000"
echo "Database host: ${db_host}"
