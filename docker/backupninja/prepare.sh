#!/bin/bash

set -e

BACKUP_DECLARATIONS=${BACKUP_DECLARATIONS:-/etc/backup.d}

cp /etc/backupninja/* /etc/backup.d/

chmod 700 -R ${BACKUP_DECLARATIONS}
chown -R root:root ${BACKUP_DECLARATIONS}
chmod 600 -R ${BACKUP_DECLARATIONS}
