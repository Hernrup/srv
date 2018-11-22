#!/bin/bash

set -e
mkdir -p /etc/backup.d
mkdir -p /var/cache/backupninja

BACKUP_DECLARATIONS=${BACKUP_DECLARATIONS:-/etc/backup.d}

cp /etc/backupninja/* /etc/backup.d/

chmod 700 -R ${BACKUP_DECLARATIONS}
chown -R root:root ${BACKUP_DECLARATIONS}
chmod 600 -R ${BACKUP_DECLARATIONS}

sed -i s/%B2_ACCOUNT_ID%/$B2_ACCOUNT_ID/g /etc/backup.d/b2.dup
sed -i s/%B2_ACCESS_TOKEN%/$B2_ACCESS_TOKEN/g /etc/backup.d/b2.dup
sed -i s/%B2_BUCKET%/$B2_BUCKET/g /etc/backup.d/b2.dup
sed -i s/%DUPLICITY_PASSPHRASE%/$DUPLICITY_PASSPHRASE/g /etc/backup.d/b2.dup
