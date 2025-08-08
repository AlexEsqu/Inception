FROM alpine:3.20

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils \
    bash

# Create mysql user and group
RUN addgroup -g 999 mysql && \
    adduser -u 999 -D -S -G mysql mysql

# Create necessary directories
RUN mkdir -p /var/lib/mysql /var/log/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/log/mysql /run/mysqld

# Copy MariaDB configuration
COPY my.cnf /etc/my.cnf
COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

# Initialize the database
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

EXPOSE 3306

USER mysql

CMD ["/setup.sh"]
