FROM alpine:3.20

RUN apk add --no-cache php \
	php-session \
	php-pdo_mysql \
	php-mysqli \
	php-fpm \
	wget \
	curl

# Sadly can't install in the docker since on shared volume
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["start.sh"]
