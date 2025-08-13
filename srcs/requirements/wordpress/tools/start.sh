#!/bin/sh

# Debug: Print environment variables
echo "=== DEBUG: Environment Variables ==="
echo "WORDPRESS_DB_HOST: $WORDPRESS_DB_HOST"
echo "WORDPRESS_DB_NAME: $WORDPRESS_DB_NAME"
echo "WORDPRESS_DB_USER: $WORDPRESS_DB_USER"
echo "WORDPRESS_DB_PASSWORD: [HIDDEN]"
echo "=================================="

# Wait for MariaDB to be ready with better error handling
echo "Waiting for MariaDB to be ready..."
MAX_TRIES=30
TRIES=0

while [ $TRIES -lt $MAX_TRIES ]; do
    # Test basic connection first
    if mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" 2>/dev/null; then
        echo "Basic database connection successful!"

        # Test database access
        if mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>/dev/null; then
            echo "Database access confirmed!"
            break
        else
            echo "Can connect to MySQL but cannot access database '$WORDPRESS_DB_NAME'"
            # Show available databases for debugging
            echo "Available databases:"
            mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SHOW DATABASES;" 2>/dev/null || echo "Cannot list databases"
        fi
    fi

    echo "Attempt $((TRIES + 1))/$MAX_TRIES: MariaDB not ready yet..."

    # Debug network connectivity every 5 attempts
    if [ $((TRIES % 5)) -eq 0 ]; then
        echo "Testing network connectivity to $WORDPRESS_DB_HOST..."
        if nc -zv "$WORDPRESS_DB_HOST" 3306 2>/dev/null; then
            echo "Port 3306 is reachable"
            # Try to get more specific error
            mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" 2>&1 | head -3
        else
            echo "Cannot reach MariaDB on port 3306"
        fi
    fi

    sleep 2
    TRIES=$((TRIES + 1))
done

if [ $TRIES -eq $MAX_TRIES ]; then
    echo "ERROR: Could not connect to MariaDB after $MAX_TRIES attempts"
    echo "Final debugging information:"
    echo "Network test:"
    nc -zv "$WORDPRESS_DB_HOST" 3306
    echo "Connection attempt output:"
    mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>&1
    exit 1
fi

echo "Database connection and access successful. Setting up WordPress..."

# Change to WordPress directory
cd /var/www/html

# Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root

    echo "WordPress installation completed!"
else
    echo "WordPress already installed."
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm81 --nodaemonize
