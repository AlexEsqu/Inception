FROM alpine:3.18

# Install nginx and openssl for SSL certificates
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    && rm -rf /var/cache/apk/*

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=mkling.42.fr"

# Create nginx user and set permissions
RUN chown -R nginx:nginx /var/lib/nginx && \
    chown -R nginx:nginx /etc/nginx/ssl

# Copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/start.sh /start.sh

# Make start script executable
RUN chmod +x /start.sh

# Create required directories
RUN mkdir -p /var/www/html && \
    chown -R nginx:nginx /var/www/html

# Expose HTTPS port
EXPOSE 443

# Start nginx
CMD ["/start.sh"]
