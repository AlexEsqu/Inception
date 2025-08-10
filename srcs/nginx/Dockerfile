FROM alpine:3.20

ARG NGINX_ADDRESS_IN_DOCKER=/var/www/html
ARG NGINX_SETUP_FILE=nginx_setup.sh
ARG NGINX_CONF_FILE=nginx.conf

# Install nginx and openssl
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p ${NGINX_ADDRESS_IN_DOCKER} \
    /var/log/nginx \
    /etc/nginx/ssl \
    /run/nginx \
    && chown -R nginx:nginx ${NGINX_ADDRESS_IN_DOCKER} /var/log/nginx /run/nginx

# Generate SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42School/OU=mkling/CN=mkling.42.fr"

# Set permissions for SSL files
RUN chmod 600 /etc/nginx/ssl/nginx.key && \
    chmod 644 /etc/nginx/ssl/nginx.crt

# Copy nginx configuration
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf

# Expose HTTPS port
EXPOSE 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

