FROM alpine:3.18

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
COPY tools/start.sh /start.sh

# Make start script executable
RUN chmod +x /start.sh

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB
CMD ["/start.sh"]
