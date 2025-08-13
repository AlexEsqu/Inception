#!/bin/sh

echo "Starting MariaDB setup..."



# Ensure proper directories exist
mkdir -p /var/run/mysqld
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/lib/mysql

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal

    # Start MariaDB temporarily without networking for initial setup
    echo "Starting MariaDB for initial setup..."
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    MYSQL_PID=$!

    # Wait for MySQL socket to be available
    echo "Waiting for MariaDB socket..."
    while [ ! -S /var/run/mysqld/mysqld.sock ]; do
        sleep 1
    done

    echo "Setting up root password, database and user..."

    # Connect via socket (no password required initially)
    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<EOF
-- Set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');

-- Create database
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE_NAME}\`;

-- Create user with access from any host
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE_NAME}\`.* TO '${MARIADB_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

    echo "Database setup completed."

    # Stop temporary MySQL
    kill $MYSQL_PID
    wait $MYSQL_PID 2>/dev/null

else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."

# Start MariaDB in foreground with proper configuration
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
