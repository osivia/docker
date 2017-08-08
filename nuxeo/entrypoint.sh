#!/bin/bash
set -e


# Public host
PUBLIC_HOST=${PUBLIC_HOST:-localhost}

CAS_HOST=${CAS_HOST:-cas}


# Nuxeo conf
NUXEO_CONF=/home/$NUXEO_USER/nuxeo.conf

# Database
NUXEO_DB_HOST=${NUXEO_DB_HOST:-postgres}
NUXEO_DB_PORT=${NUXEO_DB_PORT:-5432}
NUXEO_DB_NAME=${NUXEO_DB_NAME:-nuxeodb}
NUXEO_DB_USER=${NUXEO_DB_USER:-nuxeo}
NUXEO_DB_PASSWORD=${NUXEO_DB_PASSWORD:-osivia}

# LDAP
NUXEO_LDAP_HOST=${NUXEO_LDAP_HOST:-opendj}
NUXEO_LDAP_PORT=${NUXEO_LDAP_PORT:-389}
#NUXEO_LDAP_USER=${NUXEO_LDAP_USER:-cn=Directory manager}
#NUXEO_LDAP_PASSWORD=${NUXEO_LDAP_PASSWORD:-osivia}

# Elasticsearch
NUXEO_ES_CLUSTER=${NUXEO_ES_CLUSTER:-demo}
NUXEO_ES_NODES=${NUXEO_ES_NODES:-localhost:9300}

# Data
NUXEO_DATA=${NUXEO_DATA:-/data/nuxeo}
# Logs
NUXEO_LOGS=${NUXEO_LOGS:-/var/log/nuxeo}
# PID
NUXEO_PID=${NUXEO_PID:-/var/run/nuxeo}

# SSL
#SSL_DIRECTORY=${SSL_DIRECTORY:-/etc/ssl/nuxeo}


if [ "$1" = "nuxeoctl" ]; then
    if [ ! -f $NUXEO_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\CAS_HOST\\$CAS_HOST\\g $NUXEO_CONF

        sed -i s\\^[#]*nuxeo.db.host=.*$\\nuxeo.db.host=$NUXEO_DB_HOST\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.port=.*$\\nuxeo.db.port=$NUXEO_DB_PORT\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.name=.*$\\nuxeo.db.name=$NUXEO_DB_NAME\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.user=.*$\\nuxeo.db.user=$NUXEO_DB_USER\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.password=.*$\\nuxeo.db.password=$NUXEO_DB_PASSWORD\\g $NUXEO_CONF

        sed -i s\\^[#]*ldap.host=.*$\\ldap.host=$NUXEO_LDAP_HOST\\g $NUXEO_CONF
        sed -i s\\^[#]*ldap.port=.*$\\ldap.port=$NUXEO_LDAP_PORT\\g $NUXEO_CONF
        #sed -i s\\^[#]*ldap.manager.dn=.*$\\ldap.manager.dn=$NUXEO_LDAP_USER\\g $NUXEO_CONF
        #sed -i s\\^[#]*ldap.manager.pswd=.*$\\ldap.manager.pswd=$NUXEO_LDAP_PASSWORD\\g $NUXEO_CONF

        sed -i s\\^[#]*elasticsearch.clusterName=.*$\\elasticsearch.clusterName=$NUXEO_ES_CLUSTER\\g $NUXEO_CONF

        sed -i s\\^[#]*elasticsearch.addressList=.*$\\#elasticsearch.addressList=\\g $NUXEO_CONF
		echo "elasticsearch.addressList=$NUXEO_ES_NODES" >> $NUXEO_CONF

        # Data
        mkdir -p $NUXEO_DATA
        chown -R $NUXEO_USER: $NUXEO_DATA
        sed -i s\\^[#]*nuxeo.data.dir=.*$\\nuxeo.data.dir="${NUXEO_DATA}"\\g $NUXEO_CONF
        # Logs
        mkdir -p $NUXEO_LOGS
        chown -R $NUXEO_USER: $NUXEO_LOGS
        sed -i s\\^[#]*nuxeo.log.dir=.*$\\nuxeo.log.dir="${NUXEO_LOGS}"\\g $NUXEO_CONF
        # PID
        mkdir -p $NUXEO_PID
        chown -R $NUXEO_USER: $NUXEO_PID
        sed -i s\\^[#]*nuxeo.pid.dir=.*$\\nuxeo.pid.dir=${NUXEO_PID}\\g $NUXEO_CONF
        
        # Wizard
        sed -i s\\^[#]*nuxeo.wizard.done=.*$\\nuxeo.wizard.done=true\\g $NUXEO_CONF
        
        
        # SSL
#        mkdir -p $SSL_DIRECTORY
#        keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore $JAVA_HOME/lib/security/cacerts -srckeystore $SSL_DIRECTORY/server.p12 -srcstoretype PKCS12 -srcstorepass osivia -alias $PUBLIC_HOST
        
        
        touch $NUXEO_HOME/configured
    fi
    
    
    # Wait database
    echo "Waiting for TCP connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT..."
    while ! nc -w 1 $NUXEO_DB_HOST $NUXEO_DB_PORT 2>/dev/null; do
        sleep 1
    done
    echo "Connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT with $NUXEO_DB_USER@$NUXEO_DB_NAME"
    
    
    # Command
    NUXEO_CMD="NUXEO_CONF=$NUXEO_CONF $NUXEO_HOME/bin/$@"
    echo "NUXEO_CMD = $NUXEO_CMD"
    exec su - $NUXEO_USER -c "$NUXEO_CMD 2>&1"
fi


exec "$@"

