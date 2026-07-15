#!/bin/bash
set -e

echo "==================================================="
echo " Charlotte's Shark Facts CTF"
echo " - web (Apache + PHP) on port 80"
echo " - file server (vsftpd, read-only) on port 21"
echo "==================================================="

# Re-assert the SUID bit on base64 in case the layer was flattened (Flag 5 path).
chmod u+s /usr/bin/base64 || true

# vsftpd needs this dir to exist
mkdir -p /var/run/vsftpd/empty

# start the FTP server in the background
vsftpd /etc/vsftpd.conf &

# start Apache in the foreground (keeps the container alive)
exec apache2ctl -D FOREGROUND
