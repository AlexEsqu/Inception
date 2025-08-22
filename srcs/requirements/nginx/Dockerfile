FROM alpine:3.20

# install nginx, and openssl for SSL certificates
RUN apk update && apk add \
    nginx \
	curl \
    openssl

#  create directory for keys and certificates
RUN mkdir -p /etc/nginx/ssl

# generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/L=Paris/O=42/CN=mkling.42.fr"

# copy nginx configuration in nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# expose HTTPS port
EXPOSE 443

# start nginx with a weirdass command ending in a semicolon cuz php
CMD ["nginx", "-g", "daemon off;"]
