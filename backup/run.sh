#!/bin/bash

set -e

echo "Init started"
STDOUT_LOC=${STDOUT_LOC:-/proc/1/fd/1}
STDERR_LOC=${STDERR_LOC:-/proc/1/fd/2}

BACKUP_DECLARATIONS=${BACKUP_DECLARATIONS:-/etc/backup.d}

printenv | sed 's/^\(.*\)$/export \1/g' > /env.sh
chmod +x /env.sh

echo "Applying cron settings"
echo "0 * * * * /job.sh > ${STDOUT_LOC} 2> ${STDERR_LOC}" | crontab -
crontab -l

echo "Cron starting"
exec cron -f
