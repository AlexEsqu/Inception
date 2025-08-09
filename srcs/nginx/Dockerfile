FROM alpine:3.20

# Install nginx and openssl
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /etc/nginx/ssl \
    /run/nginx \
    && chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx

# Generate SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42School/OU=mkling/CN=mkling.42.fr"

# Set permissions for SSL files
RUN chmod 600 /etc/nginx/ssl/nginx.key && \
    chmod 644 /etc/nginx/ssl/nginx.crt

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown root:root /etc/nginx/nginx.conf && \
    chmod 644 /etc/nginx/nginx.conf

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --quiet --tries=1 --spider https://localhost:443 --no-check-certificate || exit 1

# Expose HTTPS port
EXPOSE 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

