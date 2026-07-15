# Charlotte's Shark Facts. A self-contained beginner CTF.
#
# Build:  docker build -t shark-ctf .
# Run:    docker run -d --name shark-ctf -p 80:80 -p 21:21 -p 30000-30009:30000-30009 shark-ctf

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-php \
        php-cli \
        vsftpd \
        python3 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Web root (Flags 1, 4, 6, 7, 8)
COPY web/ /var/www/html/
RUN for m in $(ls /etc/apache2/mods-available/php*.load 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.load$//'); do a2enmod "$m"; done; \
    a2dismod -f autoindex 2>/dev/null; \
    rm -f /var/www/html/index.debian.html \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \;

# Flag 8 — generate the encrypted reward (key never stored on disk)
COPY build/gen_flag8.php /build/gen_flag8.php
RUN php /build/gen_flag8.php \
    && chown -R www-data:www-data /var/www/secret \
    && chmod 644 /var/www/secret/flag8.enc.php

# Bonus - megalodon (injection -> enumeration -> base64 -> decrypt with Flag 8)
COPY build/gen_mega.php /build/gen_mega.php
COPY build/deep_template.php /build/deep_template.php
COPY build/encrypt_megalodon.py /build/encrypt_megalodon.py
RUN php /build/gen_mega.php \
    && chown -R www-data:www-data /var/www/html/deep \
    && find /var/www/html/deep -type d -exec chmod 755 {} \; \
    && find /var/www/html/deep -type f -exec chmod 644 {} \; \
    && chmod 711 /var/www/html/deep

# Flag 5 — root-owned flag, only reachable via the SUID base64 privesc
RUN printf '%s\n' \
      'LCCTF{B4Sk1Ng1500Kg} Basking sharks can weigh around 1,500 kg' \
      > /root/flag5.txt \
    && chown root:root /root/flag5.txt \
    && chmod 600 /root/flag5.txt \
    && chmod 700 /root \
    && chmod u+s /usr/bin/base64

# Flags 2 & 3 — read-only FTP file server
COPY build/make_ftp_assets.py /build/make_ftp_assets.py
COPY build/hammerhead.jpg /build/hammerhead.jpg
COPY config/vsftpd.conf /etc/vsftpd.conf

RUN useradd -m -d /home/diver -s /usr/sbin/nologin diver \
    && echo 'diver:iLoV35h4rks' | chpasswd \
    && echo '/usr/sbin/nologin' >> /etc/shells \
    && echo 'diver' > /etc/vsftpd.userlist \
    && python3 /build/make_ftp_assets.py /home/diver \
    && chown root:root /home/diver /home/diver/flag.abc \
    && chmod 555 /home/diver \
    && chmod 444 /home/diver/flag.abc \
    && mkdir -p /var/run/vsftpd/empty

# Entrypoint (starts vsftpd + apache)
COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 21 30000-30009

ENTRYPOINT ["/entrypoint.sh"]