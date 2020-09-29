#!/bin/bash

set -e

echo "Exporting env"
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

echo "Applying cron settings"
crontab /etc/backup.d/cron.cmd
crontab -l

echo "Cron starting"
exec cron -f 
