FROM alpine:3.20

RUN apk update && \
    apk add --no-cache redis

RUN mkdir -p /data

EXPOSE 6379

VOLUME ["/data"]

CMD ["redis-server", "--protected-mode", "no", "--dir", "/data", "--bind", "0.0.0.0"]
