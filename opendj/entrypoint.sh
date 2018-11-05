#!/bin/sh
set -e


if [ "$1" = "start" ]; then
    /opt/opendj/bin/start-ds --nodetach
elif [ "$1" = "backup" ]; then
	/opt/opendj/bin/export-ldif -l /backup/userRoot.ldif -n userRoot
else
    exec "$@"
fi

