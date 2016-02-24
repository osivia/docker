#!/bin/bash
set -e


# Public host
PUBLIC_HOST=${PUBLIC_HOST:-localhost}

# Portal properties
PORTAL_PROPERTIES=${PORTAL_PROPERTIES:-/home/$PORTAL_USER/portal.properties}

# Database
PORTAL_DB_HOST=${PORTAL_DB_HOST:-mysql}
PORTAL_DB_PORT=${PORTAL_DB_PORT:-3306}
PORTAL_DB_NAME=${PORTAL_DB_NAME:-portal}
PORTAL_DB_USER=${PORTAL_DB_USER:-root}
PORTAL_DB_PASSWORD=${PORTAL_DB_PASSWORD:-osivia}

# Logs
PORTAL_LOGS=${PORTAL_LOGS:-/var/log/portal}

# SSL
SSL_DIRECTORY=${SSL_DIRECTORY:-/etc/ssl/portal}


if [ "$1" = "start" ]; then
    if [ ! -f $PORTAL_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.host=.*$\\db.host=$PORTAL_DB_HOST:$PORTAL_DB_PORT\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.base-name=.*$\\db.base-name=$PORTAL_DB_NAME\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.manager.name=.*$\\db.manager.name=$PORTAL_DB_USER\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.manager.pswd=.*$\\db.manager.pswd=$PORTAL_DB_PASSWORD\\g $PORTAL_PROPERTIES
        
        # Logs
        mkdir -p $PORTAL_LOGS
        chown -R $PORTAL_USER: $PORTAL_LOGS


        # SSL
        mkdir -p $SSL_DIRECTORY
        keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore $JAVA_HOME/lib/security/cacerts -srckeystore $SSL_DIRECTORY/server.p12 -srcstoretype PKCS12 -srcstorepass osivia -alias $PUBLIC_HOST


        touch $PORTAL_HOME/configured
    fi    

    
    # Wait database
    echo "Waiting for TCP connection to $PORTAL_DB_HOST:$PORTAL_DB_PORT..."
    while ! nc -w 1 $PORTAL_DB_HOST $PORTAL_DB_PORT 1>/dev/null 2>/dev/null; do
        sleep 1
    done
    echo "Connection to $PORTAL_DB_HOST:$PORTAL_DB_PORT OK."
    
    
    # Start
    PORTAL_CMD="$PORTAL_HOME/jboss-as/bin/run.sh -c $PORTAL_CONF -b $PORTAL_HOST -P $PORTAL_PROPERTIES -DPORTAL_PROP_FILE=$PORTAL_PROPERTIES -Djboss.server.log.dir=$PORTAL_LOGS"
    echo "PORTAL_CMD = $PORTAL_CMD"
    exec su - $PORTAL_USER -c "$PORTAL_CMD 2>&1"
fi


exec "$@"

