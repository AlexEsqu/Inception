FROM alpine:3.20

RUN apk add --no-cache php \
	php-session \
	php-pdo_mysql \
	php-mysqli \
	php-fpm \
	wget \
	curl

RUN mkdir -p /var/www/adminer

RUN wget -O /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

WORKDIR /var/www/adminer

CMD ["php-fpm83", "-F"]
