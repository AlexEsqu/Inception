#!/bin/sh
set -x

DB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
DB_PASSWORD=$(cat /run/secrets/mariadb_user_password)
WP_ROOT_PASSWORD=$(cat /run/secrets/wordpress_root_password)
WP_PASSWORD=$(cat /run/secrets/wordpress_user_password)
echo "Secrets loaded successfully : ${MARIADB_DATABASE_NAME} ${MARIADB_USER} ${DB_ROOT_PASSWORD} ${DB_PASSWORD}"

echo "Waiting for MariaDB to be connectable..."
MAX_TRIES=30
TRIES=0
until mysqladmin ping -h"$MARIADB_DATABASE_NAME" -u"$MARIADB_USER" -p"$DB_PASSWORD" --silent; do
    TRIES=$((TRIES+1))
    if [ $TRIES -ge $MAX_TRIES ]; then
        echo "MariaDB is still not available after $MAX_TRIES attempts, exiting."
        exit 1
    fi
    echo "MariaDB not ready yet... ($TRIES/$MAX_TRIES)"
    sleep 2
done
echo "MariaDB is up and accepting connections!"

# Fun fact : The bad placement of this command cost me 1 full hour of debugging
cd /var/www/html

echo "Downloading WordPress..."
php -d memory_limit=512M /usr/local/bin/wp core download --allow-root

if [ ! -f wp-config.php ]; then

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

	echo "Creating a wordpress user..."
	wp user create $WORDPRESS_USER $WP_EMAIL \
		--role=author \
		--user_pass=$WP_PASSWORD \
		--allow-root

	echo "setting up redis environment values"
	wp config set WP_REDIS_HOST 'redis' --type=constant --allow-root
	wp config set WP_REDIS_PORT '6379' --type=constant --allow-root
	wp config set WP_REDIS_DATABASE '0' --type=constant --allow-root
	wp config set WP_DEBUG true --type=constant --allow-root
	wp config set WP_DEBUG_DISPLAY true --type=constant --allow-root

	wp option update blogname 'Inception'
	wp option update blogdescription 'Portfolio : Programming & Graphics Projects'

	# HTML_DIR="/var/www/html/pages"
	# wp post delete $(wp post list --post_type=page --format=ids --allow-root) --force --allow-root

	# if [ -f /var/www/html/pages/index.html ]; then
	#     echo "Creating Home page from index.html..."
	#     content=$(cat /var/www/html/pages/index.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
	#     wp post create \
	#         --post_type=page \
	#         --post_title="Home" \
	#         --post_status=publish \
	#         --post_content="$content" \
	#         --allow-root

	#     HOME_PAGE_ID=$(wp post list --post_type=page --post_title="Home" --format=ids --allow-root)
	#     wp option update show_on_front 'page' --allow-root
	#     wp option update page_on_front "$HOME_PAGE_ID" --allow-root

	#     echo "Set Home page as front page (ID: $HOME_PAGE_ID)"
	# fi

	# if [ -f /var/www/html/pages/about-me.html ]; then
	#     echo "Creating About Me page from about-me.html..."
	#     content=$(cat /var/www/html/pages/about-me.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
	#     wp post create \
	#         --post_type=page \
	#         --post_title="About Me" \
	#         --post_status=publish \
	#         --post_content="$content" \
	#         --allow-root
	# fi

	# if [ -f /var/www/html/pages/portfolio.html ]; then
	#     echo "Creating Portfolio page from portfolio.html..."
	#     content=$(cat /var/www/html/pages/portfolio.html | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
	#     wp post create \
	#         --post_type=page \
	#         --post_title="Portfolio" \
	#         --post_status=publish \
	#         --post_content="$content" \
	#         --allow-root
	# fi

	wp plugin install redis-cache --activate --allow-root
	wp redis enable --allow-root

	wp rewrite structure '/%postname%/' --hard --allow-root
	wp rewrite flush --allow-root

	echo "WordPress portfolio blog setup complete!"
	echo "WordPress installation completed!"

else
	echo "WordPress already installed."
fi

echo "Modifying the www.conf to allow connections from nginx..."
sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g'  /etc/php83/php-fpm.d/www.conf

echo "Starting PHP-FPM..."
exec php-fpm83 --nodaemonize
