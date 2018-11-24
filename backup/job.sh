#!/bin/bash
set -e
echo "Job triggerd"
echo "Setting envs"
. /env.sh
echo "Triggering backupninja"
/usr/local/sbin/backupninja -d -f /etc/backupninja.conf
