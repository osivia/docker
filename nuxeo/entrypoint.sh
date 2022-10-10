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
LDAP_HOST=${LDAP_HOST:-opendj}

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

# Mail
MAIL_HOST=${MAIL_HOST:localhost}

if [ "$1" = "start" ]; then
    if [ ! -f $NUXEO_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\CAS_HOST\\$CAS_HOST\\g $NUXEO_CONF
        sed -i s\\CAS_PUBLIC_HOST\\$PUBLIC_HOST\\g $NUXEO_CONF
        sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $NUXEO_CONF
        sed -i s\\LDAP_HOST\\$LDAP_HOST\\g $NUXEO_CONF
        sed -i s\\MAIL_HOST\\$MAIL_HOST\\g $NUXEO_CONF

        sed -i s\\^[#]*nuxeo.db.host=.*$\\nuxeo.db.host=$NUXEO_DB_HOST\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.port=.*$\\nuxeo.db.port=$NUXEO_DB_PORT\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.name=.*$\\nuxeo.db.name=$NUXEO_DB_NAME\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.user=.*$\\nuxeo.db.user=$NUXEO_DB_USER\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.password=.*$\\nuxeo.db.password=$NUXEO_DB_PASSWORD\\g $NUXEO_CONF

        sed -i s\\^[#]*elasticsearch.clusterName=.*$\\elasticsearch.clusterName=$NUXEO_ES_CLUSTER\\g $NUXEO_CONF

        sed -i s\\^[#]*elasticsearch.addressList=.*$\\#elasticsearch.addressList=\\g $NUXEO_CONF
        echo "elasticsearch.addressList=$NUXEO_ES_NODES" >> $NUXEO_CONF

        # Data
        mkdir -p $NUXEO_DATA/binaries
        cd $NUXEO_DATA/binaries
        tar xzf /opt/nxdata.tgz
        chown -R $NUXEO_USER: $NUXEO_DATA
        sed -i s\\^[#]*nuxeo.data.dir=.*$\\nuxeo.data.dir="${NUXEO_DATA}"\\g $NUXEO_CONF

        # Logs
        mkdir -p $NUXEO_LOGS
        touch $NUXEO_LOGS/server.log        
        chown -R $NUXEO_USER: $NUXEO_LOGS
        sed -i s\\^[#]*nuxeo.log.dir=.*$\\nuxeo.log.dir="${NUXEO_LOGS}"\\g $NUXEO_CONF
        # PID
        mkdir -p $NUXEO_PID
        chown -R $NUXEO_USER: $NUXEO_PID
        sed -i s\\^[#]*nuxeo.pid.dir=.*$\\nuxeo.pid.dir=${NUXEO_PID}\\g $NUXEO_CONF
        
        # Wizard
        sed -i s\\^[#]*nuxeo.wizard.done=.*$\\nuxeo.wizard.done=true\\g $NUXEO_CONF
        touch $NUXEO_HOME/configured
    fi
    
    
    # Wait database
    echo "Waiting for TCP connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT..."
    while ! nc -w 1 $NUXEO_DB_HOST $NUXEO_DB_PORT 2>/dev/null; do
        sleep 1
    done
    echo "Connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT with $NUXEO_DB_USER@$NUXEO_DB_NAME"
    
	# Command
	NUXEO_CMD="NUXEO_CONF=$NUXEO_CONF $NUXEO_HOME/bin/nuxeoctl startbg"
	echo "NUXEO_CMD = $NUXEO_CMD"
	su - $NUXEO_USER -c "$NUXEO_CMD 2>&1" &
	
	tail -f $NUXEO_LOGS/server.log

else
    exec "$@"
fi


