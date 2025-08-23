FROM alpine:3.20

RUN apk update && apk upgrade && apk add --no-cache libc6-compat curl wget

RUN wget https://dl.grafana.com/grafana-enterprise/release/12.1.1/grafana-enterprise_12.1.1_16903967602_linux_amd64.tar.gz && \
	tar -zxvf grafana-enterprise_12.1.1_16903967602_linux_amd64.tar.gz && \
	ls && \
    chmod +x grafana-12.1.1 && \
    ls -l grafana-12.1.1

RUN adduser -D -H -s /bin/false grafana

RUN mv grafana-12.1.1 /usr/local/grafana

RUN chown -R grafana: /usr/local/grafana

COPY conf/grafana.ini /usr/local/grafana/conf/grafana.ini

EXPOSE 3000

CMD ["/usr/local/grafana/bin/grafana-server", "--homepath", "/usr/local/grafana"]
