FROM alpine:3.20

# Install dependencies
RUN apk add --no-cache curl

# Download and install Hugo
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v$0.125.7/hugo_extended_$0.125.7_linux-amd64.tar.gz \
    | tar -xz -C /usr/local/bin hugo

# Create a directory for your site
WORKDIR /site

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://localhost:1313", "--appendPort=false", "--disableFastRender"]
