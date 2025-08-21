FROM alpine:3.20

RUN apk add --no-cache php php-session php-pdo_mysql php-mysqli php-fpm wget \
    && mkdir -p /var/www/html \
    && wget -O /var/www/html/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

WORKDIR /var/www/html

EXPOSE 8080

CMD ["php-fpm83", "-F"]