#!/bin/sh
set -e



if [ "$1" = "start" ]; then
    if [ ! -f $OPENDJ_HOME/configured ]; then
        echo "Configuration..."

        # Configuration
        $OPENDJ_HOME/setup --cli --baseDN dc=osivia,dc=org --ldapPort ${LDAP_PORT} --adminConnectorPort ${ADMIN_CONNECTOR_PORT} --rootUserDN cn=Directory\ Manager --rootUserPassword osivia --no-prompt --noPropertiesFile --acceptLicense
        $OPENDJ_HOME/bin/stop-ds

        # ajout schémas custom
        mv $OPENDJ_HOME/90-portal.ldif $OPENDJ_HOME/config/schema

        # modification règle des passwords
        sed -i s\\^[#]*ds-cfg-single-structural-objectclass-behavior:.*$\\ds-cfg-single-structural-objectclass-behavior:accept\\g $OPENDJ_HOME/config/config.ldif

        if [ ! -f $OPENDJ_HOME/db/dataloaded ]; then

            echo "Import des données..."
            # Import jeu de données
            $OPENDJ_HOME/bin/import-ldif --ldifFile $OPENDJ_HOME/import.ldif --backendID userRoot --rejectFile $OPENDJ_HOME/rejected-entries.log --skipFile /opt/skipped-entries.log --overwrite

            touch $OPENDJ_HOME/db/dataloaded
        fi

        touch $OPENDJ_HOME/configured
    fi

    $OPENDJ_HOME/bin/start-ds --nodetach

else
    exec "$@"
fi
