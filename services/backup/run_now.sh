#!/bin/bash
set -e
. /prepare.sh
backupninja -n -d -f /etc/backupninja.conf
