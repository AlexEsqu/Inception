#!/bin/bash

set -e

# Debug environment variables
echo "Debug: Environment variables:"
echo "WORDPRESS_DB_HOST: $WORDPRESS_DB_HOST"
echo "WORDPRESS_DB_USER: $WORDPRESS_DB_USER"
echo "WORDPRESS_DB_NAME: $WORDPRESS_DB_NAME"

# Read secrets first
DB_PASSWORD=$(cat /run/secrets/mariaDB_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)

echo "Debug: Secrets read successfully"

# Extract host and port from WORDPRESS_DB_HOST
DB_HOST=$(echo "$WORDPRESS_DB_HOST" | cut -d':' -f1)
DB_PORT=$(echo "$WORDPRESS_DB_HOST" | cut -d':' -f2)

echo "Debug: Extracted DB_HOST=$DB_HOST, DB_PORT=$DB_PORT"

# Wait for MariaDB to be ready with proper authentication
echo "Waiting for MariaDB to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    # First check if we can reach the host
    if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
        echo "Port $DB_PORT is open, testing database connection..."
        # Now test database connection
        if mariadb -h"$DB_HOST" -P"$DB_PORT" -u"$WORDPRESS_DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
            echo "MariaDB is ready!"
            break
        else
            echo "Database connection failed, but port is open"
        fi
    else
        echo "Port $DB_PORT is not reachable on host $DB_HOST"
    fi
    echo "MariaDB is not ready yet, waiting... (attempt $((attempt + 1))/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "Failed to connect to MariaDB after $max_attempts attempts"
    exit 1
fi

# Check if WordPress is already configured
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating WordPress configuration..."
    
    # Create wp-config.php
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root

    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root

    # Create additional user
    wp user create \
        "$WORDPRESS_USER" \
        "$WORDPRESS_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root

    echo "WordPress setup completed!"
else
    echo "WordPress already configured!"
fi

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm82 -F