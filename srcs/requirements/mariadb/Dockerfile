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

# Copy startup script
COPY tools/start.sh /usr/local/bin/start.sh
COPY tools/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Expose MariaDB port
EXPOSE 3306

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1;" || exit 1

# Start MariaDB
CMD ["start.sh"]
