#!/bin/bash
set -e


PORTAL_CMD_START="$PORTAL_HOME/bin/run.sh -c $PORTAL_CONF -b $PORTAL_HOST -P $PORTAL_PROPERTIES_FILE -DPORTAL_PROP_FILE=$PORTAL_PROPS_FILE -Djboss.server.log.dir=$PORTAL_LOG_DIR"


if [ "$1" = "start" ]; then
    echo "PORTAL_CMD_START = $PORTAL_CMD_START"
    $PORTAL_CMD_START 2>&1
else
    exec "$@"
fi

