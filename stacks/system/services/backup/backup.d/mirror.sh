#!/bin/bash
set -e

rsync -aPv /mnt/media_1/serials root@192.168.0.81:/mnt/disk1/backup
rsync -aPv /mnt/media_1/docs root@192.168.0.81:/mnt/disk1/backup
rsync -aPv /mnt/media_1/photos root@192.168.0.81:/mnt/disk1/backup
rsync -aPv /mnt/media_1/home_movies root@192.168.0.81:/mnt/disk1/backup
