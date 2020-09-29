#!/bin/bash
set -o pipefail

curl -X POST -H 'Content-type: application/json' \
--data '{"text":"backup started"}' \
https://hooks.slack.com/services/${SLACK_KEY}

rm -rf /var/log/backup.log
/etc/backup.d/backup.sh 2>&1 | tee -a /var/log/backup.log
CODE=$?

set -e

log=$(cat /var/log/backup.log)

if [ $CODE -eq 0 ]; then
    echo OK
    data='backup successfull '
else
    echo FAIL
    data='backup failed \n <!channel> '
fi

curl -X POST -H 'Content-type: application/json' \
--data "{\"text\":\"$data\"}" \
https://hooks.slack.com/services/${SLACK_KEY}
