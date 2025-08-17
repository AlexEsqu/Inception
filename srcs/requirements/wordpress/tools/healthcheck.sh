#!/bin/bash

if [ -f /var/www/html/wp-config.php ]; then
    if pgrep php-fpm81 >/dev/null; then
        echo "WordPress is healthy"
        exit 0
    else
        echo "PHP-FPM not running"
        exit 1
    fi
else
    echo "WordPress not installed"
    exit 1
fi