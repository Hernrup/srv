FROM ubuntu:16.04

RUN apt-get update && apt-get install wget build-essential libftdi1 libftdi-dev libconfuse0 libconfuse-dev -y

RUN echo 'deb http://download.telldus.com/debian/ stable main' > /etc/apt/sources.list

RUN wget -q http://download.telldus.com/debian/telldus-public.key -O- | apt-key add -

RUN apt-get update && apt-get install telldus-core -y

CMD ["/usr/sbin/telldusd", "--nodaemon"]

