FROM alpine:3.20

RUN apk add --no-cache hugo git

WORKDIR /site

RUN hugo new site . --force

# Add a theme
RUN git clone --depth 1 https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke && \
	echo 'theme = "ananke"' >> config.toml

COPY pages/ static/

RUN hugo new posts/my-first-post.md

EXPOSE 1313

CMD ["hugo", "server", "--bind=0.0.0.0"]
