#!/bin/bash
set -e


# Public host
PUBLIC_HOST=${PUBLIC_HOST:-localhost}

# Portal properties
PORTAL_PROPERTIES=${PORTAL_PROPERTIES:-/home/$PORTAL_USER/portal.properties}

# Database
PORTAL_DB_HOST=${PORTAL_DB_HOST:-mysql}
PORTAL_DB_PORT=${PORTAL_DB_PORT:-3306}
PORTAL_DB_NAME=${PORTAL_DB_NAME:-portaldb}
PORTAL_DB_USER=${PORTAL_DB_USER:-portal}
PORTAL_DB_PASSWORD=${PORTAL_DB_PASSWORD:-osivia}

# Nuxeo
NUXEO_HOST=${NUXEO_HOST:-nuxeo}

# LDAP
LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

# Mails
MAIL_HOST=${MAIL_HOST:-smtp.gmail.com}
MAIL_PORT=${MAIL_PORT:-587}
MAIL_USERNAME=${MAIL_USERNAME:-demo@osivia.org}
MAIL_PASSWORD=${MAIL_PASSWORD:-demo-osivia}

# CAS
CAS_HOST=${CAS_HOST:-cas}

# Cluster
PORTAL_MEMBERS=${PORTAL_MEMBERS:-""}
IFS=', ' read -r -a PORTAL_MEMBERS_ARRAY <<< $PORTAL_MEMBERS


# Logs
PORTAL_LOGS=${PORTAL_LOGS:-/var/log/portal}

# SSL
#SSL_DIRECTORY=${SSL_DIRECTORY:-/etc/ssl/portal}

#PRONOTE Secrets
PRONOTE_JWT_SECRET=${PRONOTE_JWT_SECRET:-??PRONOTESECRET??}
PRONOTE_OAUTH2_CLIENT_SECRET=${PRONOTE_OAUTH2_CLIENT_SECRET:-??PRONOTESECRET??}
PRONOTE_JWT_PUBLIC_KEY_PATH=${PRONOTE_JWT_PUBLIC_KEY_PATH:-}

#SERVICE ETABLISSEMENT
PRONOTE_ETB_SERVICE_URL_GET=${PRONOTE_ETB_SERVICE_URL_GET:-}
PRONOTE_ETB_SERVICE_URL_CHECK=${PRONOTE_ETB_SERVICE_URL_CHECK:-}

if [ "$1" = "start" ]; then
    if [ ! -f $PORTAL_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\CAS_HOST\\$CAS_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\LDAP_HOST\\$LDAP_HOST\\g $PORTAL_PROPERTIES
		
        sed -i s\\PRONOTE_JWT_SECRET\\$PRONOTE_JWT_SECRET\\g $PORTAL_PROPERTIES
        sed -i s\\PRONOTE_JWT_PUBLIC_KEY_PATH\\$PRONOTE_JWT_PUBLIC_KEY_PATH\\g $PORTAL_PROPERTIES
        
        sed -i s\\PRONOTE_OAUTH2_CLIENT_SECRET\\$PRONOTE_OAUTH2_CLIENT_SECRET\\g $PORTAL_PROPERTIES		

        sed -i s\\PRONOTE_ETB_SERVICE_URL_GET\\$PRONOTE_ETB_SERVICE_URL_GET\\g $PORTAL_PROPERTIES		
        sed -i s\\PRONOTE_ETB_SERVICE_URL_CHECK\\$PRONOTE_ETB_SERVICE_URL_CHECK\\g $PORTAL_PROPERTIES		

        sed -i s\\^[#]*db.host=.*$\\db.host=$PORTAL_DB_HOST:$PORTAL_DB_PORT\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.base-name=.*$\\db.base-name=$PORTAL_DB_NAME\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.manager.name=.*$\\db.manager.name=$PORTAL_DB_USER\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*db.manager.pswd=.*$\\db.manager.pswd=$PORTAL_DB_PASSWORD\\g $PORTAL_PROPERTIES

        sed -i s\\^[#]*nuxeo.privateHost=.*$\\nuxeo.privateHost=$NUXEO_HOST\\g $PORTAL_PROPERTIES
        
        sed -i s\\^[#]*ldap.host=.*$\\ldap.host=$LDAP_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*ldap.port=.*$\\ldap.port=$LDAP_PORT\\g $PORTAL_PROPERTIES
        
        sed -i s\\MAIL_HOST\\$MAIL_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_PORT\\$MAIL_PORT\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_USERNAME\\$MAIL_USERNAME\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_PASSWORD\\$MAIL_PASSWORD\\g $PORTAL_PROPERTIES       
        
        # Clustering web
        sed -i s\\^[#]*portal.web.cluster.tcpAddr=.*$\\portal.web.cluster.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8930]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8930]"
        done
        sed -i s\\^[#]*portal.web.cluster.initial_hosts=.*$\\portal.web.cluster.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES

        # Clustering
        sed -i s\\^[#]*portal.cluster.tcpAddr=.*$\\portal.cluster.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8920]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8920]"
        done
        sed -i s\\^[#]*portal.cluster.initial_hosts=.*$\\portal.cluster.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES

        # Custom cache
        sed -i s\\^[#]*portal.custom.cache.tcpAddr=.*$\\portal.custom.cache.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8910]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8910]"
        done
        sed -i s\\^[#]*portal.custom.cache.initial_hosts=.*$\\portal.custom.cache.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES

        # Hibernate cache
        sed -i s\\^[#]*portal.hibernate.cache.tcpAddr=.*$\\portal.hibernate.cache.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8900]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8900]"
        done
        sed -i s\\^[#]*portal.hibernate.cache.initial_hosts=.*$\\portal.hibernate.cache.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES

        # EJB3 Entity cache
        sed -i s\\^[#]*portal.ejb3.entity.cache.tcpAddr=.*$\\portal.ejb3.entity.cache.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8940]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8940]"
        done
        sed -i s\\^[#]*portal.ejb3.entity.cache.initial_hosts=.*$\\portal.ejb3.entity.cache.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES

        # SFSB cache
        sed -i s\\^[#]*portal.ejb3.sfsb.cache.tcpAddr=.*$\\portal.ejb3.sfsb.cache.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8950]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8950]"
        done
        sed -i s\\^[#]*portal.ejb3.sfsb.cache.initial_hosts=.*$\\portal.ejb3.sfsb.cache.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES
		
		
		# Connect cache
        sed -i s\\^[#]*portal.connect.cache.tcpAddr=.*$\\portal.connect.cache.tcpAddr=$HOSTNAME\\g $PORTAL_PROPERTIES
        CLUSTER_MEMBERS="$HOSTNAME[8960]"
        for element in "${PORTAL_MEMBERS_ARRAY[@]}"
        do
            CLUSTER_MEMBERS="$CLUSTER_MEMBERS,$element[8960]"
        done
        sed -i s\\^[#]*portal.connect.cache.initial_hosts=.*$\\portal.connect.cache.initial_hosts=$CLUSTER_MEMBERS\\g $PORTAL_PROPERTIES



        # Logs
        mkdir -p $PORTAL_LOGS
        touch ${PORTAL_LOGS}/server.log
        chown -R $PORTAL_USER: $PORTAL_LOGS


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

    # Redirect server.log to console
    tail -f ${PORTAL_LOGS}/server.log &

    exec su - $PORTAL_USER -c "$PORTAL_CMD"
fi


exec "$@"
