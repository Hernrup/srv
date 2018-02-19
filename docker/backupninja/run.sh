#!/bin/bash

set -e

STDOUT_LOC=${STDOUT_LOC:-/proc/1/fd/1}
STDERR_LOC=${STDERR_LOC:-/proc/1/fd/2}

BACKUP_DECLARATIONS=${BACKUP_DECLARATIONS:-/etc/backup.d}

. /prepare.sh

echo "* * * * * /usr/sbin/backupninja > ${STDOUT_LOC} 2> ${STDERR_LOC}" | crontab -
exec cron -f
