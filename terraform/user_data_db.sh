#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Database Server Setup ==="

# Update system
dnf update -y

# Install MySQL 8
dnf install -y mysql-server

# Start MySQL
systemctl start mysqld
systemctl enable mysqld

# Secure MySQL installation (automated)
# Set root password
MYSQL_ROOT_PASSWORD="CrazyClothes2026SecurePass"
mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"

# Create database and user
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS cc;
CREATE USER IF NOT EXISTS 'ccuser'@'%' IDENTIFIED BY 'CrazyClothes2026User';
GRANT ALL PRIVILEGES ON cc.* TO 'ccuser'@'%';
FLUSH PRIVILEGES;
EOF

# Configure MySQL to listen on all interfaces
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf
systemctl restart mysqld

# Download and import database dump from S3 (you'll need to upload it first)
# aws s3 cp s3://your-bucket/database-dump.sql /tmp/database-dump.sql
# mysql -u root -p"$MYSQL_ROOT_PASSWORD" cc < /tmp/database-dump.sql

echo "=== Database Server Setup Complete ==="
echo "MySQL Root Password: $MYSQL_ROOT_PASSWORD"
echo "Database: cc"
echo "User: ccuser"
echo "Password: CrazyClothes2026User"
