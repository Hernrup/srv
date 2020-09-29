#!/bin/bash
set -e

/bin/prepare.sh

restic backup \
    --host srv \
    --tag personal \
    --exclude-caches \
    --exclude-file /etc/backup.d/exclude.txt \
    -v \
    --cache-dir /cache \
    -o b2.connections=10 \
    /mnt/media_1/serials \
    /mnt/media_1/docs \
    /mnt/media_1/photos \
    /mnt/media_1/home_movies

restic forget --keep-last 2 \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --keep-yearly 3 \
  --tag personal \
  --host srv \
  --cache-dir /cache \
  -v

restic backup \
    --host srv \
    --tag appdata \
    --exclude-caches \
    --exclude-file /etc/backup.d/exclude.txt \
    -v \
    --cache-dir /cache \
    -o b2.connections=10 \
    /var/data \

restic forget \
  --keep-weekly 3 \
  --tag appdata \
  --host srv \
  --cache-dir /cache \
  -v

# --with-cache - limits Class B Transactions on BackBlaze B2 see: https://forum.restic.net/t/limiting-b2-transactions/209/4
restic check --with-cache

/etc/backup.d/mirror.sh