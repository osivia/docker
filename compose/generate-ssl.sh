#!/bin/sh

set -e


BASEDIR=$(dirname $0)
PUBLIC_HOST=osivia-portal

cd $BASEDIR
rm -rf ssl
mkdir ssl

cd $BASEDIR/ssl
openssl req -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/CN=$PUBLIC_HOST"
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 999
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name $PUBLIC_HOST -CAfile server.cacert -password pass:osivia -caname root
