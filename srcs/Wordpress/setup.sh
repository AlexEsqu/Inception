#!/bin/bash

# Read passwords from secrets
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)

echo "Waiting for database connection..."
while ! mysql -h$WORDPRESS_DB_HOST -u$WORDPRESS_DB_USER -p$MYSQL_PASSWORD -e "SELECT 1" > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 3
done

echo "Database connected successfully!"

# Change to WordPress directory
cd /var/www/html

# Download WordPress core if not exists
if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."

    # Download WordPress
    wp core download --allow-root

    # Create wp-config.php
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --dbcharset=utf8mb4 \
        --dbcollate=utf8mb4_unicode_ci \
        --allow-root

    # Install WordPress
    wp core install \
        --url=$WORDPRESS_URL \
        --title="$WORDPRESS_TITLE" \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --allow-root

    # Create additional user
    wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL \
        --user_pass=$WORDPRESS_USER_PASSWORD \
        --role=author \
        --allow-root

    # Install a simple theme (optional)
    wp theme install twentytwentyfour --activate --allow-root

    echo "WordPress setup completed!"
else
    echo "WordPress already configured!"
fi

# Set proper ownership
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm82 -F
