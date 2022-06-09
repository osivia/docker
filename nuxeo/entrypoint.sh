#!/bin/bash
set -e


# Nuxeo conf
NUXEO_CONF=/home/$NUXEO_USER/nuxeo.conf
# Data
NUXEO_DATA=${NUXEO_DATA:-/data/nuxeo}
# Logs
NUXEO_LOGS=${NUXEO_LOGS:-/var/log/nuxeo}
# PID
NUXEO_PID=${NUXEO_PID:-/var/run/nuxeo}

if [ "$1" = "start" ]; then


    if [ ! -f $NUXEO_HOME/configured ]; then

        # Data
        mkdir -p $NUXEO_DATA
        chown -R $NUXEO_USER: $NUXEO_DATA
        sed -i s\\^[#]*nuxeo.data.dir=.*$\\nuxeo.data.dir="${NUXEO_DATA}"\\g $NUXEO_CONF
        # Logs
        mkdir -p $NUXEO_LOGS
        touch $NUXEO_LOGS/server.log        
        chown -R $NUXEO_USER: $NUXEO_LOGS
        sed -i s\\^[#]*nuxeo.log.dir=.*$\\nuxeo.log.dir="${NUXEO_LOGS}"\\g $NUXEO_CONF
        # PID
        mkdir -p $NUXEO_PID
        chown -R $NUXEO_USER: $NUXEO_PID
        sed -i s\\^[#]*nuxeo.pid.dir=.*$\\nuxeo.pid.dir=${NUXEO_PID}\\g $NUXEO_CONF

    fi

	# Command
	NUXEO_CMD="NUXEO_CONF=$NUXEO_CONF JAVA_HOME=/usr/local/openjdk-8 $NUXEO_HOME/bin/nuxeoctl startbg"
	echo "NUXEO_CMD = $NUXEO_CMD"
	su - $NUXEO_USER -c "$NUXEO_CMD 2>&1" &
	
	tail -f $NUXEO_LOGS/server.log
fi

