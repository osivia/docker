#!/bin/bash
set -e

PORTAL_HOSTS=${PORTAL_HOSTS:-"portal1, portal2"}
NUXEO_HOST=${NUXEO_HOST:-nuxeo}
CAS_HOST=${CAS_HOST:-cas}

IFS=', ' read -r -a PORTAL_NODES_ARRAY <<< $PORTAL_HOSTS

HTTPD_HOME=/root
HTTPD_CONFIG_FILE=/usr/local/apache2/conf/extra/reverse-proxy.conf

CERTS_FILES=/etc/ssl


if [ ! -f $HTTPD_HOME/configured ]; then
    echo "Configuration..."

    # Ajout configration reverse proxy  
    echo "# OSIVIA Platform" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/reverse-proxy.conf" >> /usr/local/apache2/conf/httpd.conf    

	if [ ! -f $CERTS_FILES/server.crt ]; then
    	openssl req -nodes -newkey rsa:2048 -keyout $CERTS_FILES/server.key -out $CERTS_FILES/server.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/OU=Portal/CN=$HOSTNAME"
    	openssl x509 -req -in $CERTS_FILES/server.csr -signkey $CERTS_FILES/server.key -out $CERTS_FILES/server.crt -days 999
    fi

    sed -i s\\NUXEO_HOST\\$NUXEO_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\CAS_HOST\\$CAS_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\OO_HOST\\$OO_HOST\\g $HTTPD_CONFIG_FILE
    
    sed -i s\\CERTS_FILES\\$CERTS_FILES\\g $HTTPD_CONFIG_FILE
    
    
    for element in "${PORTAL_NODES_ARRAY[@]}"
    do
        echo "BalancerMember http://${element}:8080 route=${element}" >> members.txt
    done
    
    sed -i '/BalancerMembers/r members.txt' $HTTPD_CONFIG_FILE

    touch $HTTPD_HOME/configured
fi    

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND
