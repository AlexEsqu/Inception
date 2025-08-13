#!/bin/sh

# Ensure proper permissions
chown -R nginx:nginx /var/www/html
chown -R nginx:nginx /var/log/nginx

# Test nginx configuration
nginx -t

# Start nginx in foreground
exec nginx -g "daemon off;"
