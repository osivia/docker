#!/bin/bash
set -e

PORTAL_HOSTS=${PORTAL_HOSTS:-"portal1, portal2"}
NUXEO_HOST=${NUXEO_HOST:-nuxeo}
CAS_HOST=${CAS_HOST:-cas}
WEBMAIL_HOST=${WEBMAIL_HOST:-fakesmtp-web}

HTTPS_PROVIDED=${HTTPS_PROVIDED:-false}


IFS=', ' read -r -a PORTAL_NODES_ARRAY <<< $PORTAL_HOSTS

HTTPD_HOME=/root


HTTPD_CONFIG_FILE=/usr/local/apache2/conf/extra/reverse-proxy.conf


if [ ! -f $HTTPD_HOME/configured ]; then
    echo "Configuration..."

    # Add configration reverse proxy  
	echo "# OSIVIA Platform" >> /usr/local/apache2/conf/httpd.conf
    echo "Include conf/extra/reverse-proxy.conf" >> /usr/local/apache2/conf/httpd.conf    
    
	# Set common header of the config file
	touch $HTTPD_CONFIG_FILE
    cat /tmp/rv-0-head >> $HTTPD_CONFIG_FILE

	# If https is not provided by an upstream server, we provide it and create a self-signed certificate.
	# http urls are forced to https default port
	if [ "$HTTPS_PROVIDED" = false ]; then
		
		echo "set up SSL..."
		
		#HTTPD_SSL_CONFIG_FILE=/usr/local/apache2/conf/extra/ssl.conf
		cat /tmp/rv-1-vh-https >> $HTTPD_CONFIG_FILE
		
		CERTS_FILES=/etc/ssl
		if [ ! -f $CERTS_FILES/server.crt ]; then
	    	openssl req -nodes -newkey rsa:2048 -keyout $CERTS_FILES/server.key -out $CERTS_FILES/server.csr -subj "/C=FR/ST=Loire-Atlantique/L=Nantes/O=OSIVIA/OU=Portal/CN=$HOSTNAME"
	    	openssl x509 -req -in $CERTS_FILES/server.csr -signkey $CERTS_FILES/server.key -out $CERTS_FILES/server.crt -days 999
	    fi
	    
	    sed -i s\\CERTS_FILES\\$CERTS_FILES\\g $HTTPD_CONFIG_FILE
	   
	else
		cat /tmp/rv-1-vh-http_only >> $HTTPD_CONFIG_FILE
	
	fi

	# Set proxy and headers in the config file
	cat /tmp/rv-2-proxy >> $HTTPD_CONFIG_FILE

	# sed with named servers
    sed -i s\\PUBLIC_HOST\\$PUBLIC_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\NUXEO_HOST\\$NUXEO_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\CAS_HOST\\$CAS_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\OO_HOST\\$OO_HOST\\g $HTTPD_CONFIG_FILE
    sed -i s\\WEBMAIL_HOST\\$WEBMAIL_HOST\\g $HTTPD_CONFIG_FILE
       
    
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
