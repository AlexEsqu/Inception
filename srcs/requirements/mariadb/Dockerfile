FROM alpine:3.20

# Install MariaDB
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils \
    && rm -rf /var/cache/apk/*

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/mysql /var/log/mysql /run/mysqld

# Copy configuration files
COPY conf/my.cnf /etc/my.cnf

# Copy startup script
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB
CMD ["start.sh"]
