#!/bin/bash
set -e

if [ ! -f $CATALINA_HOME/configured ]; then
    echo "Configuration..."


    touch $CATALINA_HOME/configured
fi    

mkdir -p $CATALINA_HOME/conf/Catalina/localhost
mv $CATALINA_HOME/ws-toutatice-content-store.xml $CATALINA_HOME/conf/Catalina/localhost

catalina.sh jpda run

