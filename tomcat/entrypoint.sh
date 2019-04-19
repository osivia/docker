#!/bin/bash
set -e

# LDAP
PUBLIC_HOST=${PUBLIC_HOST:-"localhost"}

LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

CAS_PROPERTIES=$CAS_CONFIG/cas.properties

if [ ! -f $CAS_CONFIG/configured ]; then
	
	
    echo "Configuration..."

    sed -i s\\^[#]*ldap.url=.*$\\#ldap.url\\g $CAS_PROPERTIES
	echo "ldap.url=ldap://${LDAP_HOST}:${LDAP_PORT}" >> $CAS_PROPERTIES

    
    echo "Register public cert in keystore for https client..."
    
    openssl pkcs12 -export -in /export/httpd/ssl/server.crt -inkey /export/httpd/ssl/server.key -out /etc/ssl/server.p12 -name ${PUBLIC_HOST} -password pass:osivia -caname root  || { exit 1; }
	keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore ${JAVA_HOME}/lib/security/cacerts -srckeystore /etc/ssl/server.p12 -srcstoretype PKCS12 -srcstorepass osivia -alias ${PUBLIC_HOST} || { exit 1; }
	
    touch $CAS_CONFIG/configured
	
fi    

catalina.sh jpda run

