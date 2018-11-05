#!/bin/sh
BACKUP_DIR=/backup
FILE="$(date +%Y%m%d_%H%M%S)"

mkdir -p ${BACKUP_DIR}

# Create backup user if needed
id -u backup &>/dev/null || useradd backup

echo 'ARCHIVING ....'
chown -R backup:backup ${BACKUP_DIR}

for old_file in $(find ${BACKUP_DIR}/* -mtime +5)
do :
	echo 'suppression ' ${old_file}
	su - backup -c "rm ${old_file}"
done


#### Postgres db
echo "dump Postgres ${POSTGRES_DB}"
pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} | gzip > ${BACKUP_DIR}/postgres_${db}_${FILE}.sql.gz

