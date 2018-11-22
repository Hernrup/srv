#!/bin/bash

set -e

. /prepare.sh

backupninja -n --run /etc/backup.d/b2.dup
