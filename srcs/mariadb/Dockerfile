FROM alpine:3.20

ARG MARIADB_ADDRESS_IN_DOCKER=/var/lib/mysql
ARG MARIADB_VOLUME_ADDRESS_IN_HOSTMACHINE=/var/lib/mysql
ARG MARIADB_CONF_FILE=my.conf
ARG MARIADB_STARTUP_FILE=mariadb_setup.sh

# Install MariaDB and required packages
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    bash

# Copy configuration and script files
COPY ${MARIADB_STARTUP_FILE} /usr/local/bin/${MARIADB_STARTUP_FILE}

# Set permissions for the startup script
RUN chmod +x /usr/local/bin/${MARIADB_STARTUP_FILE}

# Start the setup script as root, it will switch to mysql user internally
CMD /usr/local/bin/${MARIADB_STARTUP_FILE}