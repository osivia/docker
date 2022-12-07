#!/bin/bash
set -e


# Public host
PUBLIC_HOST=${PUBLIC_HOST:-localhost}

# Portal properties
PORTAL_PROPERTIES=${PORTAL_PROPERTIES:-/home/$PORTAL_USER/portal.properties}

# Nuxeo
NUXEO_HOST=${NUXEO_HOST:-nuxeo}

# LDAP
LDAP_HOST=${LDAP_HOST:-opendj}
LDAP_PORT=${LDAP_PORT:-1389}

# Mails
MAIL_HOST=${MAIL_HOST:-localhost}
#MAIL_PORT=${MAIL_PORT:-587}
#MAIL_USERNAME=${MAIL_USERNAME:-demo@osivia.org}
#MAIL_PASSWORD=${MAIL_PASSWORD:-demo-osivia}

# CAS
CAS_HOST=${CAS_HOST:-cas}

# SSL
#SSL_DIRECTORY=${SSL_DIRECTORY:-/etc/ssl/portal}


if [ "$1" = "start" ]; then
    if [ ! -f $PORTAL_HOME/configured ]; then
        echo "Configuration..."
    
        # Properties
        sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\CAS_HOST\\$CAS_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\LDAP_HOST\\$LDAP_HOST\\g $PORTAL_PROPERTIES

        sed -i s\\^[#]*nuxeo.privateHost=.*$\\nuxeo.privateHost=$NUXEO_HOST\\g $PORTAL_PROPERTIES
        
        sed -i s\\^[#]*ldap.host=.*$\\ldap.host=$LDAP_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\^[#]*ldap.port=.*$\\ldap.port=$LDAP_PORT\\g $PORTAL_PROPERTIES
        
		    sed -i s\\^[#]*mail.smtp.host=.*$\\mail.smtp.host=$MAIL_HOST\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_PORT\\$MAIL_PORT\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_USERNAME\\$MAIL_USERNAME\\g $PORTAL_PROPERTIES
        sed -i s\\MAIL_PASSWORD\\$MAIL_PASSWORD\\g $PORTAL_PROPERTIES       

        # h5p
        chown $PORTAL_USER: /opt/h5p

        touch $PORTAL_HOME/configured
    fi    


    # Wait nuxeo
#    echo "Waiting for TCP connection to $NUXEO_HOST:8080..."
#    while ! nc -w 1 $NUXEO_HOST 8080 1>/dev/null 2>/dev/null; do
#        sleep 1
#    done
#    echo "Connection to $NUXEO_HOST:8080 OK."

    export JPDA_ADDRESS=8787

    /opt/portal/bin/catalina.sh jpda run
fi


exec "$@"
