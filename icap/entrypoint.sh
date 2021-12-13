#!/bin/bash
set -e


/usr/bin/c-icap -f /etc/c-icap/c-icap.conf -D -N

rm /var/run/c-icap/c-icap.id 


