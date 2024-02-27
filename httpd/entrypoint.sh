#!/bin/bash
set -e

IFS=', ' read -r -a PORTAL_NODES_ARRAY <<< $PORTAL_HOSTS

HTTPD_HOME=/root

CERTS_FILES=/etc/ssl/certs


if [ ! -f $HTTPD_HOME/configured ]; then
    echo "Configuration..."

    # Ajout configration reverse proxy  

    echo "Include conf/extra/reverse-proxy.conf" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/tribu.conf" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/collabora.conf" >> /usr/local/apache2/conf/httpd.conf

	if [ ! -f $CERTS_FILES/server.crt ]; then
    	openssl req -nodes -newkey rsa:2048 -keyout $CERTS_FILES/server.key -out $CERTS_FILES/server.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/OU=Portal/CN=tribu.local"
    	openssl x509 -req -in $CERTS_FILES/server.csr -signkey $CERTS_FILES/server.key -out $CERTS_FILES/server.crt -days 999
    fi

	if [ ! -f $CERTS_FILES/server-collabora.crt ]; then
    	openssl req -nodes -newkey rsa:2048 -keyout $CERTS_FILES/server-collabora.key -out $CERTS_FILES/server-collabora.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/OU=Portal/CN=collabora.tribu.local"
    	openssl x509 -req -in $CERTS_FILES/server-collabora.csr -signkey $CERTS_FILES/server-collabora.key -out $CERTS_FILES/server-collabora.crt -days 999
    fi

    touch $HTTPD_HOME/configured
fi    

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND
