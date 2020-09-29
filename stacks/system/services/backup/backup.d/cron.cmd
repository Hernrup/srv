SHELL=/bin/bash
BASH_ENV=/container.env
0 4 * * SUN /etc/backup.d/backup-wrapper.sh > /proc/1/fd/1 2>/proc/1/fd/2
