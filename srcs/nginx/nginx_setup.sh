#!/bin/sh
set -e

echo "Starting nginx startup script..."

# # Function to check if MariaDB is ready
# wait_for_mariadb() {
#     echo "Waiting for MariaDB to be ready..."
#     max_attempts=30
#     attempt=0
    
#     while [ $attempt -lt $max_attempts ]; do
#         # Try to connect to MariaDB container on port 3306
#         if nc -z mariadb 3306 >/dev/null 2>&1; then
#             echo "MariaDB is ready!"
#             return 0
#         fi
        
#         echo "MariaDB not ready, attempt $((attempt + 1))/$max_attempts"
#         sleep 2
#         attempt=$((attempt + 1))
#     done
    
#     echo "ERROR: MariaDB failed to become ready after $max_attempts attempts"
#     return 1
# }

# # Function to check if WordPress is ready
# wait_for_wordpress() {
#     echo "Waiting for WordPress to be ready..."
#     max_attempts=30
#     attempt=0
    
#     while [ $attempt -lt $max_attempts ]; do
#         # Try to connect to WordPress container on port 9000
#         if nc -z wordpress 9000 >/dev/null 2>&1; then
#             echo "WordPress is ready!"
#             return 0
#         fi
        
#         echo "WordPress not ready, attempt $((attempt + 1))/$max_attempts"
#         sleep 2
#         attempt=$((attempt + 1))
#     done
    
#     echo "ERROR: WordPress failed to become ready after $max_attempts attempts"
#     return 1
# }

# # Wait for dependencies
# wait_for_mariadb
# wait_for_wordpress

# # Test nginx configuration before starting
# echo "Testing nginx configuration..."
# if ! nginx -t; then
#     echo "ERROR: nginx configuration test failed"
#     exit 1
# fi

# echo "nginx configuration test passed"

# # Create nginx health check file
# echo "OK" > /var/www/html/health.html

# # Start nginx in foreground
# echo "Starting nginx..."

mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MO/ST=KH/O=42/OU=42/CN=${USER}.42.fr"

exec nginx -g "daemon off;"