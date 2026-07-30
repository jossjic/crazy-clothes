#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Database Server Setup ==="

# Install MySQL 8.0 Community Server (NOT available in AL2023 base
# repos — must add Oracle's official repo first). DO NOT use
# mariadb1011-server / mariadbXXX-server as a substitute: MariaDB has
# real SQL incompatibilities with MySQL 8 syntax used by this app
# (verified 2026-07-30 — see section 5, ORDER BY on aggregate alias
# fails with ER_ILLEGAL_REFERENCE on MariaDB, works fine on MySQL 8).
curl -sLo /tmp/mysql-release.rpm https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
dnf install -y /tmp/mysql-release.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
dnf install -y --refresh mysql-community-server

systemctl start mysqld
systemctl enable mysqld
sleep 3

# MySQL 8 generates a random temporary root password on first init,
# written to the log — must extract it before we can do anything else.
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# MySQL 8's validate_password component rejects weak passwords by
# default. The FIRST password change must satisfy the default MEDIUM
# policy (upper+lower+digit+special char) before you can relax the
# policy — verified 2026-07-30, using the final target password
# directly on this first ALTER USER fails with ERROR 1819.
mysql -u root -p"$TEMP_PASS" --connect-expired-password \
  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'TempPass2026!Ok';"

mysql -u root -p'TempPass2026!Ok' -e "
  SET GLOBAL validate_password.policy=LOW;
  CREATE DATABASE IF NOT EXISTS cc;
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'CrazyClothes2026SecurePass';
  CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'CrazyClothes2026SecurePass';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  CREATE USER IF NOT EXISTS 'ccuser'@'%' IDENTIFIED BY 'CrazyClothes2026User';
  GRANT ALL PRIVILEGES ON cc.* TO 'ccuser'@'%';
  FLUSH PRIVILEGES;
"

sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mysqld.cnf 2>/dev/null \
  || echo 'bind-address = 0.0.0.0' >> /etc/my.cnf.d/mysqld.cnf
systemctl restart mysqld
sleep 3

# Download and import database dump from S3
aws s3 cp s3://crazy-clothes-deploy-660759882203/database-dump.sql /tmp/database-dump.sql
mysql -u root -pCrazyClothes2026SecurePass cc < /tmp/database-dump.sql

echo "=== Database Server Setup Complete ==="
