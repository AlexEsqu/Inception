#!/bin/bash

set -e

# Read secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mariaDB_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/mariaDB_password)

# Ensure proper ownership and permissions
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql
chmod 755 /var/lib/mysql

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Initialize as mysql user
    su-exec mysql mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm --auth-root-authentication-method=normal
    
    # Start temporary MariaDB instance for setup (with networking disabled for setup)
    su-exec mysql mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/tmp/mysql_temp.sock &
    MYSQL_PID=$!
    
    # Wait for MariaDB to start
    echo "Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mysqladmin ping --socket=/tmp/mysql_temp.sock --silent; then
            break
        fi
        echo "MariaDB is starting... $i seconds remaining"
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo "MariaDB failed to start"
        exit 1
    fi
    
    echo "Setting up database and users..."
    
    # Execute setup SQL
    mysql --socket=/tmp/mysql_temp.sock -u root << EOF
-- Set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create database and user
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

    echo "Database setup completed!"
    
    # Stop the temporary instance
    mysqladmin --socket=/tmp/mysql_temp.sock -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
    wait $MYSQL_PID
    
else
    echo "Database already initialized!"
fi

# Start MariaDB normally with networking enabled
echo "Starting MariaDB with networking..."
exec su-exec mysql mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306