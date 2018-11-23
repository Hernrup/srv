FROM ubuntu:18.04

RUN apt-get update && apt-get install gawk git bash duplicity autotools-dev automake make build-essential openssh-client debconf-utils genisoimage rdiff-backup rsync trickle gzip bzip2 cron dialog -y

RUN apt-get update --fix-missing
RUN apt-get install python2.7 python-pip python3-pip -y
RUN pip2 install B2
RUN pip3 install requests

RUN git clone https://0xacab.org/riseuplabs/backupninja.git /tmp/bn && \
cd /tmp/bn && \
./autogen.sh && ./configure && make && make install

RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:duplicity-team/ppa && apt-get update && apt-get --only-upgrade install duplicity -y

## We are going to remove the default backupninja cron. Check the `run` init CMD script to see how we do it instead.
RUN rm -f /etc/cron.d/backupninja

## Remove package list to save space
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.ssh
ADD run.sh /run.sh
ADD run_now.sh /run_now.sh
ADD prepare.sh /prepare.sh
ADD bin /bin

CMD ["/run.sh"]
