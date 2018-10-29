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


#    sed -i s\\PUBLIC_HOST\\$HOSTNAME\\g $HTTPD_CONFIG_FILE
    sed -i s\\NUXEO_HOST\\$NUXEO_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\CAS_HOST\\$CAS_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\OO_HOST\\$OO_HOST\\g $HTTPD_CONFIG_FILE    
	
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

