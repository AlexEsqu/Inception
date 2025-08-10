FROM alpine:3.20

ARG WORDPRESS_ADDRESS_IN_DOCKER=/var/www/html
ARG WORDPRESS_WWW_CONF_FILE=www.conf
ARG WORDPRESS_STARTUP_SCRIPT=wordpress_setup.sh

# Install PHP and required extensions in one layer
RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-phar \
    mariadb-client \
    bash \
    curl \
    su-exec \
    ca-certificates \
    && rm -rf /var/cache/apk/*

RUN		sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php81/php-fpm.d/www.conf

# Download and install WP-CLI
RUN curl -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
    
# Copy configuration files
COPY ${WORDPRESS_WWW_CONF_FILE} /etc/php82/php-fpm.d/www.conf
COPY ${WORDPRESS_STARTUP_SCRIPT} /usr/local/bin/${WORDPRESS_STARTUP_SCRIPT}

# Set proper permissions
RUN chmod +x /usr/local/bin/${WORDPRESS_STARTUP_SCRIPT} && \
    chmod 644 /etc/php82/php-fpm.d/www.conf && \
    chown www-data:www-data /usr/local/bin/${WORDPRESS_STARTUP_SCRIPT}



# Expose PHP-FPM port
EXPOSE 9000

# Switch to www-data user for runtime
USER www-data

# Set working directory
WORKDIR ${WORDPRESS_ADDRESS_IN_DOCKER}

# Start the setup script
CMD /usr/local/bin/wordpress_setup.sh