FROM alpine:3.20

# Install PHP-FPM and required extensions
RUN apk update && apk add --no-cache \
    php \
    php-fpm \
    php-mysqli \
    php-json \
    php-curl \
    php-dom \
    php-exif \
    php-fileinfo \
    php-mbstring \
    php-openssl \
    php-xml \
    php-zip \
    php-redis \
    php-ftp \
    php-ctype \
    php-session \
    php-tokenizer \
    php-imagick \
    php-gd \
    php-iconv \
    php-phar \
    php-sodium \
    mysql-client \
    curl \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/www/html /var/log/php /var/www/html/pages /run/php

# Copy startup script
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Download WP-CLI and put it in the path as wp
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Expose PHP-FPM port
EXPOSE 9000

# start wordpress install, then wordpress proper
CMD ["start.sh"]
