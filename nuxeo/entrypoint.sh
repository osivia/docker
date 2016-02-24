#!/bin/bash
set -e


# Public host
PUBLIC_HOST=${PUBLIC_HOST:-localhost}

# Nuxeo conf
NUXEO_CONF=/home/$NUXEO_USER/nuxeo.conf

# Database
NUXEO_DB_HOST=${NUXEO_DB_HOST:-postgres}
NUXEO_DB_PORT=${NUXEO_DB_PORT:-5432}
NUXEO_DB_NAME=${NUXEO_DB_NAME:-nuxeo}
NUXEO_DB_USER=${NUXEO_DB_USER:-nuxeo}
NUXEO_DB_PASSWORD=${NUXEO_DB_PASSWORD:-osivia}

# Data
NUXEO_DATA=${NUXEO_DATA:-/data/nuxeo}
# Logs
NUXEO_LOGS=${NUXEO_LOGS:-/var/log/nuxeo}
# PID
NUXEO_PID=${NUXEO_LOGS:-/var/run/nuxeo}

# SSL
SSL_DIRECTORY=${SSL_DIRECTORY:-/etc/ssl/nuxeo}


if [ "$1" = "nuxeoctl" ]; then
    if [ ! -f $NUXEO_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.host=.*$\\nuxeo.db.host=$NUXEO_DB_HOST\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.port=.*$\\nuxeo.db.port=$NUXEO_DB_PORT\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.name=.*$\\nuxeo.db.name=$NUXEO_DB_NAME\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.user=.*$\\nuxeo.db.user=$NUXEO_DB_USER\\g $NUXEO_CONF
        sed -i s\\^[#]*nuxeo.db.password=.*$\\nuxeo.db.password=$NUXEO_DB_PASSWORD\\g $NUXEO_CONF
    
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
        mkdir -p $SSL_DIRECTORY
        keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore $JAVA_HOME/lib/security/cacerts -srckeystore $SSL_DIRECTORY/server.p12 -srcstoretype PKCS12 -srcstorepass osivia -alias $PUBLIC_HOST
        
        
        touch $NUXEO_HOME/configured
    fi
    
    
    # Wait database
    echo "Waiting for TCP connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT..."
    while ! nc -w 1 $NUXEO_DB_HOST $NUXEO_DB_PORT 2>/dev/null; do
        sleep 1
    done
    echo "Connection to $NUXEO_DB_HOST:$NUXEO_DB_PORT OK"
    
    
    # Command
    NUXEO_CMD="NUXEO_CONF=$NUXEO_CONF $NUXEO_HOME/bin/$@"
    echo "NUXEO_CMD = $NUXEO_CMD"
    exec su - $NUXEO_USER -c "$NUXEO_CMD 2>&1"
fi


exec "$@"

