FROM alpine:3.18

# Install PHP-FPM and required extensions
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-redis \
    php81-ftp \
    php81-ctype \
    php81-session \
    php81-tokenizer \
    php81-pecl-imagick \
    php81-gd \
    php81-iconv \
    php81-phar \
    php81-sodium \
    mysql-client \
    curl \
    sudo \
    && rm -rf /var/cache/apk/*

# Create www-data user and group
RUN adduser -u 82 -D -S -G www-data www-data

# Create necessary directories
RUN mkdir -p /var/www/html /var/log/php81 && \
    chown -R www-data:www-data /var/www/html /var/log/php81

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf
COPY conf/php.ini /etc/php81/php.ini

# Copy startup script
COPY tools/start.sh /start.sh

# Make scripts executable
RUN chmod +x /start.sh

# Download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Start as root to handle permissions, then switch to www-data
CMD ["/start.sh"]
