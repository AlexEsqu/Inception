FROM alpine:3.20

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    gettext

# Create nginx user and group
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/ssl /var/www/html

# Generate stronger SSL certificate with better parameters
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Generate Diffie-Hellman parameters for better security
RUN openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown -R nginx:nginx /var/log/nginx /var/cache/nginx /var/www/html \
    && chmod 600 /etc/nginx/ssl/nginx.key \
    && chmod 644 /etc/nginx/ssl/nginx.crt \
    && chmod 644 /etc/nginx/ssl/dhparam.pem

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

