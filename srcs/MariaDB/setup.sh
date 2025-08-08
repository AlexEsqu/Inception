#!/bin/bash

# Read passwords from secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)

# Start MariaDB in safe mode
mysqld_safe --skip-networking &

# Wait for MariaDB to start
while ! mysqladmin ping -h localhost --silent; do
    sleep 1
done

# Set root password and create database/user
mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE;
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Stop the safe mode instance
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# Start MariaDB normally
exec mysqld --user=mysql
