FROM ubuntu:20.04

RUN apt-get update && apt-get install gawk git bash restic autotools-dev automake make build-essential rsync gzip bzip2 cron dialog wget python3-dev python3-pip curl -y

RUN apt-get update --fix-missing
RUN rm -rf /var/lib/apt/lists/*

RUN pip3 install requests

RUN mkdir -p /root/.ssh

ADD bin /bin

CMD ["/bin/run.sh"]
