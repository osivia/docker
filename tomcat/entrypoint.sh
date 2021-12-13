#!/bin/bash
set -e

# LDAP
PUBLIC_HOST=${PUBLIC_HOST:-"localhost"}

LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

PRONOTE_SERVICEVALIDATE_URL=${PRONOTE_SERVICEVALIDATE_URL:-"https://PUBLIC_HOST/pronote-ws/serviceValidate"}

CAS_PROPERTIES=/etc/cas/cas.properties


if [ ! -f $CATALINA_HOME/configured ]; then
	
    echo "Configuration..."
    
    sed -i s\\PRONOTE_SERVICEVALIDATE_URL\\$PRONOTE_SERVICEVALIDATE_URL\\g $CAS_PROPERTIES
    
	sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $CAS_PROPERTIES
    sed -i s\\^[#]*ldap.url=.*$\\#ldap.url\\g $CAS_PROPERTIES
	echo "ldap.url=ldap://${LDAP_HOST}:${LDAP_PORT}" >> $CAS_PROPERTIES
		
    echo "Register public cert in keystore for https client..."
    
    openssl pkcs12 -export -in /export/httpd/ssl/server.crt -inkey /export/httpd/ssl/server.key -out /etc/ssl/server.p12 -name ${PUBLIC_HOST} -password pass:osivia -caname root  || { exit 1; }
	keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore ${JAVA_HOME}/lib/security/cacerts -srckeystore /etc/ssl/server.p12 -srcstoretype PKCS12 -srcstorepass osivia -alias ${PUBLIC_HOST} || { exit 1; }
	
    touch $CATALINA_HOME/configured
	
fi    

catalina.sh jpda run

