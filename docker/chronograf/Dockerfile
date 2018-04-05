FROM chronograf:1.4.2.3-alpine

# Static stuff that is unlikely to ever change.
CMD ["containerpilot"]

run apk --no-cache add \
    bash \
    curl \
    vim \
    unzip

# Install Consul
RUN export CONSUL_VERSION=0.9.2 \
    && export CONSUL_CHECKSUM=0a2921fc7ca7e4702ef659996476310879e50aeeecb5a205adfdbe7bd8524013 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /var/consul

# Install Consul template
RUN export CONSUL_TEMPLATE_VERSION=0.19.0 \
    && export CONSUL_TEMPLATE_SHA1=31dda6ebc7bd7712598c6ac0337ce8fd8c533229887bd58e825757af879c5f9f \
    && curl --retry 7 -Lso /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_SHA1}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && rm /tmp/consul-template.zip

# Install Containerpilot
ENV CONTAINERPILOT=/etc/containerpilot.json5
RUN export CONTAINERPILOT_VER=3.6.1 \
    && export CONTAINERPILOT_CHECKSUM=57857530356708e9e8672d133b3126511fb785ab \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Copy all needed files.
COPY files /

# Seems to be needed for telegraf input system.
RUN touch /var/run/utmp

# Set timezone to Sweden.
ENV TZ=Europe/Stockholm
RUN apk --no-cache add tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# ENV BOLT_PATH=/var/lib/chronograf
WORKDIR /var/lib/chronograf
