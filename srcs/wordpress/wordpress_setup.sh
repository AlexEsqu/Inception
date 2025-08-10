#!/bin/bash
set -e

# Read secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/mariaDB_root_password)
DB_PASSWORD=$(cat /run/secrets/mariaDB_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)
echo "Secrets loaded successfully"

echo "Using database username password: ${MARIADB_ADMIN_USER} and database name: ${DB_NAME}"
for ((i = 1; i <= 10; i++)); do
    if mysql -u root -P 3306 \
        -u "${MARIADB_ADMIN_USER}" \
        -p"${DB_ROOT_PASSWORD}" -e "SELECT 1"; then
        break
    else
        echo "Waiting for MariaDB to be ready... Attempt $i"
        sleep 2
    fi
done

wp core download --allow-root
wp config create \
    --dbname=${DB_NAME} \
    --dbuser=${DB_USER} \
    --dbpass=${DB_PASSWORD} \
    --dbhost=mariadb:3306 --allow-root
wp core install \
    --url=${DOMAIN} \
    --title=${WP_TITLE} \
    --admin_user=${WP_ADMIN_USER} \
    --admin_password=${WP_ADMIN_PASSWORD} \
    --admin_email=${WP_ADMIN_EMAIL} --allow-root
wp user create ${WP_USER_NAME} ${WP_USER_EMAIL} \
    --user_pass=${WP_USER_PASSWORD} \
    --role=${WP_USER_ROLE} --allow-root

wp theme install twentytwentyfour --activate --allow-root

# wp plugin install redis-cache --activate --allow-root
# wp config set WP_REDIS_HOST redis --allow-root
# wp config set WP_REDIS_PORT 6379 --raw --allow-root
# wp redis enable --allow-root

chown -R www-data:www-data /var/www/html

mkdir -p /run/php
/usr/sbin/php-fpm7.4 -F

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm82 -F