#!/bin/bash

echo "Creating secrets directory..."
mkdir -p ../.secrets
mkdir -p ../.secrets/mariadb
mkdir -p ../.secrets/wordpress
mkdir -p ../.secrets/ftp

echo "Please set the environment for this project:"
read -p "Enter WORDPRESS_URL [mkling.42.fr]: " WORDPRESS_URL
WORDPRESS_URL=${WORDPRESS_URL:-mkling.42.fr}

read -p "Enter WORDPRESS_TITLE [inception]: " WORDPRESS_TITLE
WORDPRESS_TITLE=${WORDPRESS_TITLE:-Inception}

read -p "Enter MARIADB_USER [wp_user]: " MARIADB_USER
MARIADB_USER=${MARIADB_USER:-wp_user}

read -p "Enter WP_ADMIN [MewTwo]: " WP_ADMIN
WP_ADMIN=${WP_ADMIN:-MewTwo}

read -p "Enter WP_USER [mkling]: " WP_USER
WP_USER=${WP_USER:-mkling}

read -p "Enter FTP_USER [ftpuser]: " FTP_USER
FTP_USER=${FTP_USER:-ftpuser}


# Would be better practice to generate random values,
# but for ease in evaluation I chose a default
read -s -p "Enter MARIADB_USER_PASSWORD [???]: " MARIADB_USER_PASSWORD
MARIADB_USER_PASSWORD=${MARIADB_USER_PASSWORD:-bronzekey}
# if [ -z "$MARIADB_USER_PASSWORD" ]; then
#   MARIADB_USER_PASSWORD=$(openssl rand -base64 16)
# fi
echo ""

read -s -p "Enter MARIADB_ROOT_PASSWORD [???]: " MARIADB_ROOT_PASSWORD
MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD:-skeletonkey}
echo ""

read -s -p "Enter WP_USER_PASSWORD [???]: " WP_USER_PASSWORD
WP_USER_PASSWORD=${WP_USER_PASSWORD:-bronzekey}
echo ""

read -s -p "Enter WP_ADMIN_PASSWORD [???]: " WP_ADMIN_PASSWORD
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-skeletonkey}
echo ""

read -s -p "Enter FTP_PASSWORD [???]: " FTP_PASSWORD
FTP_PASSWORD=${FTP_PASSWORD:-bronzekey}
echo ""

echo "Adding env file..."
cat > .env <<EOF
# Mariadb setup
MARIADB_DATABASE_NAME=mariadb
MARIADB_USER=$MARIADB_USER
WORDPRESS_DB_NAME=wordpress_db

# Wordpress setup
WORDPRESS_URL=https://${WORDPRESS_URL}
WORDPRESS_DOMAIN=${WORDPRESS_URL}
WORDPRESS_TITLE=$WORDPRESS_TITLE
WORDPRESS_ADMIN_USER=$WP_ADMIN
WORDPRESS_ADMIN_EMAIL=example@gmail.com
WORDPRESS_USER=$WP_USER
WORDPRESS_USER_EMAIL=example@gmail.com

# FTP setup
FTP_USER=$FTP_USER
EOF
echo ".env file created!"

echo "Creating .secret files to be mounted..."
echo "$MARIADB_USER_PASSWORD" > ../.secrets/mariadb/mariadb_user_password.txt
echo "$MARIADB_ROOT_PASSWORD" > ../.secrets/mariadb/mariadb_root_password.txt
echo "$WP_ADMIN_PASSWORD" > ../.secrets/wordpress/wordpress_root_password.txt
echo "$WP_USER_PASSWORD" > ../.secrets/wordpress/wordpress_user_password.txt
echo "$FTP_PASSWORD" > ../.secrets/ftp/ftp_password.txt
echo ".secret files created!"

# chmod 600 ../.secrets/*
# chmod 700 ../.secrets/

