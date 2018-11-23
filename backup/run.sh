#!/bin/bash

set -e

STDOUT_LOC=${STDOUT_LOC:-/proc/1/fd/1}
STDERR_LOC=${STDERR_LOC:-/proc/1/fd/2}

BACKUP_DECLARATIONS=${BACKUP_DECLARATIONS:-/etc/backup.d}

. /prepare.sh

echo "*/10 * * * * . /env.sh; /usr/local/sbin/backupninja --run /etc/backup.d/b2.dup > ${STDOUT_LOC} 2> ${STDERR_LOC}" | crontab -
exec cron -f
