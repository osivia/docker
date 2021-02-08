#!/bin/bash
set -e

if [ ! -f $CATALINA_HOME/configured ]; then

    cd $CATALINA_HOME/webapps
    unzip -q tribu-app.zip

    touch $CATALINA_HOME/configured

fi    

catalina.sh jpda run

