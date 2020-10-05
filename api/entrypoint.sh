#!/bin/bash
set -e

if [ ! -f $CATALINA_HOME/configured ]; then
    echo "Configuration..."

    mkdir -p $CATALINA_HOME/conf/Catalina/localhost
    mv $CATALINA_HOME/ws-tribu-api.xml $CATALINA_HOME/conf/Catalina/localhost
    mv $CATALINA_HOME/api-users.xml $CATALINA_HOME/conf

    touch $CATALINA_HOME/configured
fi    

catalina.sh jpda run

