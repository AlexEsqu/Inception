#!/bin/bash

# Read password from environment or secrets
DB_PASSWORD=${MYSQL_ROOT_PASSWORD:-$(cat /run/secrets/mariadb_root_password)}

# Test database connection
if mariadb -u root -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "MariaDB is healthy"
    exit 0
else
    echo "MariaDB health check failed"
    exit 1
fi