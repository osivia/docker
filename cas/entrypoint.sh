#!/bin/bash
set -e

# Tomcat
CAS_TOMCAT_PORT=${CAS_TOMCAT_PORT:-8080}
CAS_TOMCAT_ADMIN_PORT=${CAS_TOMCAT_ADMIN_PORT:-8005}
CAS_TOMCAT_AJP_PORT=${CAS_TOMCAT_AJP_PORT:-8009}

# LDAP
LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

CAS_PROPERTIES=$CAS_CONFIG/cas.properties
SERVER_XML=$CATALINA_HOME/conf/server.xml

if [ ! -f $CAS_CONFIG/configured ]; then
    echo "Configuration..."

    sed -i s\\CAS_TOMCAT_PORT\\$CAS_TOMCAT_PORT\\g $SERVER_XML
    sed -i s\\CAS_TOMCAT_ADMIN_PORT\\$CAS_TOMCAT_ADMIN_PORT\\g $SERVER_XML
    sed -i s\\CAS_TOMCAT_AJP_PORT\\$CAS_TOMCAT_AJP_PORT\\g $SERVER_XML

    sed -i s\\^[#]*ldap.url=.*$\\#ldap.url\\g $CAS_PROPERTIES
	echo "ldap.url=ldap://${LDAP_HOST}:${LDAP_PORT}" >> $CAS_PROPERTIES

    touch $CAS_CONFIG/configured
fi    

catalina.sh jpda run

