FROM alpine:3.21

RUN apk update && apk add --no-cache \
	openssl \
	curl \
	ca-certificates \
	nginx

COPY website.conf /etc/nginx/sites-available/$(WEBSITE_ADRESS)

RUN sudo mkdir -p /var/www/html/$(WEBSITE_ADRESS)

RUN sudo chown -R $USER:$USER /var/www/html/$(WEBSITE_ADRESS)

COPY index.html /usr/share/nginx/html/$(WEBSITE_ADRESS)/index.html

RUN sudo ln -s /etc/nginx/sites-available/$(WEBSITE_ADRESS) /etc/nginx/sites-enabled

CMD ["sudo nginx"]

