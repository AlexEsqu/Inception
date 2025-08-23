#!/bin/sh
set -ex

FTP_USER=${FTP_USER:-ftpuser}
echo "FTP_USER is: $FTP_USER"

echo "Reading secrets..."
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

echo "Adding user..."
if ! id "$FTP_USER" >/dev/null 2>&1; then
    adduser -D -h /home/$FTP_USER $FTP_USER
    id "$FTP_USER" || (echo "User $FTP_USER not found after adduser!" && exit 1)
fi

echo "Setting user and passwords..."
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

chmod a-w /var/www/html

echo "Launching vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
