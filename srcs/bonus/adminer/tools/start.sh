#!/bin/sh
set -xe

ADMINER_DIR="/var/www/html/adminer"
ADMINER_FILE="${ADMINER_DIR}/latest.php"  # Changed to match Nginx config

# Create directory if it doesn't exist
mkdir -p ${ADMINER_DIR}

# Download Adminer if it doesn't exist
if [ ! -f "$ADMINER_FILE" ]; then
    echo "Downloading Adminer..."
    wget -O ${ADMINER_FILE} "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php"

    # Set proper permissions
    chmod 644 ${ADMINER_FILE}

    # Create index file to redirect to latest.php
    echo '<?php header("Location: latest.php"); ?>' > ${ADMINER_DIR}/index.php
    chmod 644 ${ADMINER_DIR}/index.php

    # Also create a symlink for direct access
    ln -sf ${ADMINER_FILE} ${ADMINER_DIR}/index.php

    echo "Adminer installed successfully!"
else
    echo "Adminer already installed."
fi

# Configure PHP-FPM to listen on all interfaces
echo "Configuring PHP-FPM..."

# Check if sed succeeded
if ! grep -q "listen = 0.0.0.0:9000" /etc/php83/php-fpm.d/www.conf; then
    echo "ERROR: Failed to configure PHP-FPM to listen on all interfaces"
    cat /etc/php83/php-fpm.d/www.conf | grep listen
    exit 1
fi

# Make sure the PHP-FPM user can access the files
chown -R nobody:nobody ${ADMINER_DIR}

# Debug information
echo "Files in ${ADMINER_DIR}:"
ls -la ${ADMINER_DIR}

echo "PHP-FPM configuration:"
grep "listen =" /etc/php83/php-fpm.d/www.conf

echo "Starting PHP-FPM..."
exec php-fpm83 -F
