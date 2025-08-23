FROM alpine:3.20

RUN apk add --no-cache php \
	php-session \
	php-pdo_mysql \
	php-mysqli \
	php-fpm \
	wget \
	curl

RUN mkdir -p /var/www/adminer \
	&& curl -o /var/www/adminer/index.php https://www.adminer.org/latest.php

RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:8080/g' /etc/php83/php-fpm.d/www.conf

EXPOSE 8080

CMD ["php-fpm83", "--nodaemonize"]
