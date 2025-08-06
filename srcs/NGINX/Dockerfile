FROM alpine:3.21

RUN apk update && apk add --no-cache \
	openssl \
	curl \
	ca-certificates \
	nginx

COPY index.html /usr/share/nginx/html/index.html

CMD ["sudo nginx"]

