#!/bin/sh
set -e

if [ ! -f $OPENDJ_HOME/configured ]; then
	
	# Setup directory server
	$OPENDJ_HOME/setup \
          --cli \
          --baseDN dc=osivia,dc=org \
          --ldapPort ${LDAP_PORT} \
          --adminConnectorPort ${ADMIN_CONNECTOR_PORT} \
          --rootUserDN cn=Directory\ Manager \
          --rootUserPassword osivia \
          --no-prompt \
          --noPropertiesFile \
          --acceptLicense

    
	## Configuration
	# Allow pre encoded passwords
	$OPENDJ_HOME/bin/dsconfig -w osivia  -X -n set-password-policy-prop --policy-name "Default Password Policy" --advanced --set allow-pre-encoded-passwords:true --trustAll
	# Create unique constraint for mail field
	$OPENDJ_HOME/bin/dsconfig create-plugin -w osivia --plugin-name "Unique mail address" --type unique-attribute --set enabled:true --set base-dn:dc=osivia,dc=org --set type:mail --trustAll --no-prompt
	
	$OPENDJ_HOME/bin/stop-ds
	
	# install custom schemas 
	mv /opt/90-portal.ldif $OPENDJ_HOME/config/schema
	
	$OPENDJ_HOME/bin/import-ldif --ldifFile /opt/import.ldif --backendID userRoot --rejectFile /opt/rejected-entries.log --skipFile /opt/skipped-entries.log --overwrite          
          
	touch $OPENDJ_HOME/configured
fi    


if [ "$1" = "start" ]; then
    /opt/opendj/bin/start-ds --nodetach
elif [ "$1" = "backup" ]; then
	/opt/opendj/bin/export-ldif -l /backup/userRoot.ldif -n userRoot
else
    exec "$@"
fi

