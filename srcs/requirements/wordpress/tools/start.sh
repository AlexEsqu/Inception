#!/bin/sh

# Read secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
DB_PASSWORD=$(cat /run/secrets/mariadb_user_password)
WP_ROOT_PASSWORD=$(cat /run/secrets/wordpress_root_password)
WP_PASSWORD=$(cat /run/secrets/wordpress_user_password)
echo "Secrets loaded successfully : ${MARIADB_DATABASE_NAME} ${MARIADB_USER} ${DB_ROOT_PASSWORD} ${DB_PASSWORD}"


# Debug: Print environment variables
echo "=== DEBUG: Environment Variables ==="
echo "WORDPRESS_DB_NAME: $MARIADB_DATABASE_NAME"
echo "MARIADB_USER: $MARIADB_USER"
echo "WORDPRESS_DB_PASSWORD: [HIDDEN]"
echo "=================================="

# Wait for MariaDB to be ready with better error handling
echo "Waiting for MariaDB to be ready..."
MAX_TRIES=30
TRIES=0

while [ $TRIES -lt $MAX_TRIES ]; do
    # Test basic connection first
    if mysql -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" 2>/dev/null; then
        echo "Basic database connection successful!"

        # Test database access
        if mysql -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>/dev/null; then
            echo "Database access confirmed!"
            break
        else
            echo "Can connect to MySQL but cannot access database '$WORDPRESS_DB_NAME'"
            # Show available databases for debugging
            echo "Available databases:"
            mysql -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" 2>/dev/null || echo "Cannot list databases"
        fi
    fi

    echo "Attempt $((TRIES + 1))/$MAX_TRIES: MariaDB not ready yet..."

    # Debug network connectivity every 5 attempts
    if [ $((TRIES % 5)) -eq 0 ]; then
        echo "Testing network connectivity to $MARIADB_DATABASE_NAME..."
        if nc -zv "$MARIADB_DATABASE_NAME" 3306 2>/dev/null; then
            echo "Port 3306 is reachable"
            # Try to get more specific error
            mysql -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" 2>&1 | head -3
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
    nc -zv "$MARIADB_DATABASE_NAME" 3306
    echo "Connection attempt output:"
    mysql -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>&1
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
        --dbuser="$MARIADB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$MARIADB_DATABASE_NAME" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WP_ROOT_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root

    # wp theme install https://public-api.wordpress.com/rest/v1/themes/download/mpho.zip --activate --allow-root

    # Install and activate plugins
    wp plugin install elementor wpforms-lite wordpress-seo disable-comments limit-login-attempts-reloaded --activate --allow-root

    # Set site title & tagline
    wp option update blogname 'Inception'
    wp option update blogdescription 'Portfolio : Programming & Graphics Projects'

    HTML_DIR="/var/www/html/pages"

    # Remove default "Hello World" post
    echo "Removing default 'Hello World' post..."
    wp post delete 1 --force --allow-root
    wp post delete $(wp post list --post_type=page --title="Sample Page" --format=ids --allow-root) --force --allow-root

    # Create home page from index.html
    if [ -f /var/www/html/pages/index.html ]; then
        echo "Creating Home page from index.html..."
        
        # Read HTML content
        content=$(cat /var/www/html/pages/index.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
        
        # Create WordPress page as home page
        wp post create \
            --post_type=page \
            --post_title="Home" \
            --post_status=publish \
            --post_content="$content" \
            --allow-root
        
        # Get the page ID
        HOME_PAGE_ID=$(wp post list --post_type=page --post_title="Home" --format=ids --allow-root)
        
        # Set as front page
        wp option update show_on_front 'page' --allow-root
        wp option update page_on_front "$HOME_PAGE_ID" --allow-root
        
        echo "Set Home page as front page (ID: $HOME_PAGE_ID)"
    fi
    
    if [ -f /var/www/html/pages/about-me.html ]; then
        echo "Creating About Me page from about-me.html..."
        
        content=$(cat /var/www/html/pages/about-me.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
        
        wp post create \
            --post_type=page \
            --post_title="About Me" \
            --post_status=publish \
            --post_content="$content" \
            --allow-root
        
        # Get the page ID
        HOME_PAGE_ID=$(wp post list --post_type=page --post_title="Home" --format=ids --allow-root)
        
    fi

    if [ -f /var/www/html/pages/portfolio.html ]; then
        echo "Creating Portfolio page from portfolio.html..."
        
        content=$(cat /var/www/html/pages/portfolio.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
        
        wp post create \
            --post_type=page \
            --post_title="Portfolio" \
            --post_status=publish \
            --post_content="$content" \
            --allow-root
        
        # Get the page ID
        HOME_PAGE_ID=$(wp post list --post_type=page --post_title="Home" --format=ids --allow-root)
        
    fi

    # Set pretty permalinks
    wp rewrite structure '/%postname%/' --hard --allow-root
    wp rewrite flush --allow-root

    # Disable file editing
    echo "define('DISALLOW_FILE_EDIT', true);" >> wp-config.php

    echo "WordPress portfolio blog setup complete!"


    echo "WordPress installation completed!"
else
    echo "WordPress already installed."
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm81 --nodaemonize
