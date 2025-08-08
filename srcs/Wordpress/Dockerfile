FROM alpine:3.20

# Install PHP and required extensions in one layer
RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-intl \
    php82-bcmath \
    php82-ctype \
    php82-filter \
    php82-ftp \
    php82-gd \
    php82-iconv \
    php82-simplexml \
    php82-soap \
    php82-tokenizer \
    php82-xmlreader \
    php82-xmlwriter \
    php82-session \
    php82-posix \
    mariadb-client \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Create www-data user and group with proper shell
RUN addgroup -g 82 -S www-data && \
    adduser -u 82 -D -S -G www-data -s /bin/bash www-data

# Create necessary directories with proper permissions
RUN mkdir -p /var/www/html /run/php /var/log/php-fpm && \
    chown -R www-data:www-data /var/www/html /run/php /var/log/php-fpm

# Download and install WordPress as www-data user
USER www-data
WORKDIR /var/www/html

RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Switch back to root for system configurations
USER root

# Download and install WP-CLI with verification
RUN curl -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    curl -o wp-cli.phar.sha512 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.sha512 && \
    sha512sum -c wp-cli.phar.sha512 && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    rm wp-cli.phar.sha512

# Copy configuration files
COPY --chown=root:root www.conf /etc/php82/php-fpm.d/www.conf
COPY --chown=root:root php.ini /etc/php82/conf.d/99-custom.ini
COPY --chown=root:root setup.sh /usr/local/bin/setup.sh

# Set proper permissions for scripts and configs
RUN chmod +x /usr/local/bin/setup.sh && \
    chmod 644 /etc/php82/php-fpm.d/www.conf && \
    chmod 644 /etc/php82/conf.d/99-custom.ini

# Create PHP-FPM log directory
RUN mkdir -p /var/log/php82 && \
    chown www-data:www-data /var/log/php82

# Set final ownership for WordPress files
RUN chown -R www-data:www-data /var/www/html

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD php-fpm82 -t || exit 1

# Expose PHP-FPM port
EXPOSE 9000

# Switch to www-data user for runtime
USER www-data

# Set working directory
WORKDIR /var/www/html

# Start the setup script
CMD ["/usr/local/bin/setup.sh"]
