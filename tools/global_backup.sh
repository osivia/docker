#!/bin/sh
PREFIX=tribu
SUFFIX=1
BKP_HOST=vm-lbi-foad
BKP_HOSTDIR=/backup

LOGDIR=/home/loic

WORKDIR=/tmp/backups/
mkdir -p ${WORKDIR}

cd ../compose

# ===== hot backup postgres, perform a pg_dump directly in the container =====
docker-compose exec postgres /root/bin/backup.sh
docker cp ${PREFIX}_postgres_${SUFFIX}:/backup/ ${WORKDIR}/sql

# ===== cold backup opendj, run a clone container with export-ldif command =====
docker-compose stop opendj

docker ps -a > /tmp/containers.list
# if backup container found
if grep --quiet ${PREFIX}_opendj_backup /tmp/containers.list; then
	echo "Perform opendj backup"
	docker start -a ${PREFIX}_opendj_backup
# else, create backup container
else
	echo "Create backup container and perform opendj backup"
	docker run -v ${PREFIX}_opendj-data:/opt/opendj/db -v ${PREFIX}_opendj-backup:/backup --name ${PREFIX}_opendj_backup opendj:tribu backup
fi
docker cp ${PREFIX}_opendj_${SUFFIX}:/backup/ ${WORKDIR}/ldap

docker-compose start opendj

# Get the date
repDate=`date +%Y%m%d`;

# Cleanup first (anything older than 21 days)
duplicity remove-older-than 14D -v9 --force scp://root@${BKP_HOST}/${BKP_HOSTDIR}

# Now do the backup
export PASSPHRASE=osivia
duplicity full ${WORKDIR} scp://root@${BKP_HOST}/${BKP_HOSTDIR} > ${LOGDIR}/full_Backup_Log_$repDate_localmachine_admin.log

# Get the disk space
echo "Available Disk Space on Server" >> ${LOGDIR}/full_Backup_Log_$repDate_localmachine_admin.log
echo >> ${LOGDIR}/full_Backup_Log_$repDate_localmachine_admin.log
ssh root@${BKP_HOST} df -h >> ${LOGDIR}/full_Backup_Log_$repDate_localmachine_admin.log

# Mail me the results
#mail -t localuser -s "localmachine Backup Full (Admin)" < /home/localuser/Documents/BackupLogs/Full_Backup_Log_$repDate_localmachine_admin.log

