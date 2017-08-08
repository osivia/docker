#!/bin/bash
set -e

# LDAP
LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-389}

CAS_PROPERTIES=$CAS_HOME/cas-config.properties

if [ ! -f $CAS_HOME/configured ]; then
    echo "Configuration..."

    sed -i s\\^[#]*ldap.url=.*$\\#ldap.url\\g $CAS_PROPERTIES
	echo "ldap.url=ldap://${LDAP_HOST}:${LDAP_PORT}" >> $CAS_PROPERTIES

    touch $CAS_HOME/configured
fi    

catalina.sh run
