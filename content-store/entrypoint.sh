#!/bin/bash
set -e

CAS_PROPERTIES=$CAS_HOME/cas-config.properties

if [ ! -f $CATALINA_HOME/configured ]; then
    echo "Configuration..."


    touch $CATALINA_HOME/configured
fi    


catalina.sh jpda run

