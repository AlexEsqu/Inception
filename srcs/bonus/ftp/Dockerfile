FROM alpine:3.20

RUN apk update && \
    apk add --no-cache vsftpd

# Add a basic vsftpd.conf
COPY conf/vsftp.conf /etc/vsftpd/vsftpd.conf

# Create FTP user and home directory
RUN adduser -D -h /home/ftpuser ftpuser && \
    echo "ftpuser:ftppassword" | chpasswd && \
    mkdir -p /home/ftpuser/ftp && \
    chown -R ftpuser:ftpuser /home/ftpuser

EXPOSE 21

CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]