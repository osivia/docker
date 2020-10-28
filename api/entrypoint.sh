#!/bin/bash
set -e

if [ ! -f $CATALINA_HOME/configured ]; then

    touch $CATALINA_HOME/configured
fi    

catalina.sh jpda run

