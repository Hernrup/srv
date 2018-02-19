FROM ubuntu:14.04

RUN apt-get update
RUN apt-get upgrade

RUN apt-get update && \
    apt-get install openssh-client debconf-utils duplicity genisoimage rdiff-backup rsync trickle gzip bzip2 cron dialog -y && \
    ## Here are defined extras depending on the sort of backups youll be having the ninjas run ;)
    apt-get install mysql-client postgresql-client subversion subversion-tools -y && \
    apt-get build-dep backupninja -y && \
    rm -rf /var/lib/apt/lists/*


## Installing backupninja from our custom built debian package
ADD backupninja_1.0.1-2_4019-rsync-bug-fixed_all.deb /tmp/backupninja.deb
RUN dpkg -i /tmp/backupninja.deb

# Now we can install ssmtp, shouldn't be any incompatibilities with backupninja
RUN apt-get update && apt-get install ssmtp -y

## We are going to remove the default backupninja cron. Check the `run` init CMD script to see how we do it instead.
RUN rm -f /etc/cron.d/backupninja

RUN mkdir -p /root/.ssh
ADD run.sh /run.sh
ADD run_now.sh /run_now.sh
add prepare.sh /prepare.sh

CMD ["/run.sh"]
