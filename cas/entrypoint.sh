#!/bin/bash
set -e

# LDAP
LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

CAS_PROPERTIES=$CAS_CONFIG/cas.properties

if [ ! -f $CAS_CONFIG/configured ]; then
    echo "Configuration..."

    sed -i s\\^[#]*ldap.url=.*$\\#ldap.url\\g $CAS_PROPERTIES
	echo "ldap.url=ldap://${LDAP_HOST}:${LDAP_PORT}" >> $CAS_PROPERTIES

    touch $CAS_CONFIG/configured
fi    

catalina.sh jpda run

