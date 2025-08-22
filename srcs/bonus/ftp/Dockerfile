FROM alpine:3.20

RUN apk update && \
	apk add --no-cache vsftpd

COPY conf/vsftp.conf /etc/vsftpd/vsftpd.conf
COPY tools/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 21

CMD ["/start.sh"]
