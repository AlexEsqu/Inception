FROM alpine:3.20

# Install MariaDB and required packages
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    bash \
    su-exec \
    && rm -rf /var/cache/apk/*

# Create necessary directories with proper permissions
RUN mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql && \
    chmod 755 /var/lib/mysql

# Copy configuration files
COPY my.conf /etc/my.cnf
COPY setup.sh /setup.sh

# Set proper permissions
RUN chmod +x /setup.sh && \
    chmod 644 /etc/my.cnf

# Expose MariaDB port
EXPOSE 3306

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD mysqladmin ping -h localhost || exit 1

# Start the setup script as root, it will switch to mysql user internally
CMD ["/setup.sh"]
