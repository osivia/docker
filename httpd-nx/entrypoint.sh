#!/bin/bash
set -e

NUXEO_HOSTS=${NUXEO_HOSTS:-""}

IFS=', ' read -r -a NUWEO_NODES_ARRAY <<< $NUXEO_HOSTS

HTTPD_HOME=/root
HTTPD_CONFIG_FILE=/usr/local/apache2/conf/extra/nuxeo-proxy.conf



if [ ! -f $HTTPD_HOME/configured ]; then
    echo "Configuration..."

    # Ajout configration reverse proxy  
    echo "# OSIVIA Platform" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/nuxeo-proxy.conf" >> /usr/local/apache2/conf/httpd.conf    
    
    
    for element in "${NUWEO_NODES_ARRAY[@]}"
    do
        echo "BalancerMember http://${element}:8080 route=${element}" >> members.txt
    done
    sed -i '/BalancerMembers/r members.txt' $HTTPD_CONFIG_FILE

    touch $HTTPD_HOME/configured
fi    

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND
