#!/bin/sh
set -e


if [ "$1" = "start" ]; then
    /opt/opendj/bin/start-ds --nodetach
else
    exec "$@"
fi

