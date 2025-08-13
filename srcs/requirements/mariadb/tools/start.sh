#!/bin/sh

echo "Starting MariaDB setup..."

# Read secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
DB_PASSWORD=$(cat /run/secrets/mariadb_user_password)
echo "Secrets loaded successfully : ${MARIADB_DATABASE_NAME} ${MARIADB_USER} ${DB_ROOT_PASSWORD} ${DB_PASSWORD}"

# Ensure proper directories exist
mkdir -p /var/run/mysqld
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/lib/mysql

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."

    # Initialize a database on the volume and start MariaDB in the background
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
        --auth-root-authentication-method=socket >/dev/null 2>/dev/null
    mysqld_safe &
    mysqld_pid=$!

    # Wait for the server to be started, then set up database and accounts
    mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
    cat << EOF | mysql --protocol=socket -u root -p=
CREATE DATABASE $WORDPRESS_DB_NAME;
CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$MARIADB_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$DB_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

    # Shut down the temporary server and mark the volume as initialized
    mysqladmin shutdown

else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."

# Start MariaDB in foreground with proper configuration
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
