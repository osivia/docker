#!/bin/bash
set -e

PORTAL_HOSTS=${PORTAL_HOSTS:-"portal1, portal2"}
NUXEO_HOST=${NUXEO_HOST:-nuxeo}
CAS_HOST=${CAS_HOST:-cas}

IFS=', ' read -r -a PORTAL_NODES_ARRAY <<< $PORTAL_HOSTS

HTTPD_HOME=/root
HTTPD_CONFIG_FILE=/usr/local/apache2/conf/extra/reverse-proxy.conf


if [ ! -f $HTTPD_HOME/configured ]; then
    echo "Configuration..."

    # Ajout configration reverse proxy  
    echo "# OSIVIA Platform" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/reverse-proxy.conf" >> /usr/local/apache2/conf/httpd.conf    

	if [ ! -f /etc/ssl/server.crt ]; then
    	openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/OU=Portal/CN=$HOSTNAME"
    	openssl x509 -req -in /etc/ssl/server.csr -signkey /etc/ssl/server.key -out /etc/ssl/server.crt -days 999
    fi

    sed -i s\\NUXEO_HOST\\$NUXEO_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\CAS_HOST\\$CAS_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\OO_HOST\\$OO_HOST\\g $HTTPD_CONFIG_FILE
    
    
    for element in "${PORTAL_NODES_ARRAY[@]}"
    do
        echo "BalancerMember http://${element}:8080 route=${element}" ping=10ms >> members.txt
    done
    sed -i '/BalancerMembers/r members.txt' $HTTPD_CONFIG_FILE

    touch $HTTPD_HOME/configured
fi    

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND
