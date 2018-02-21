#!/bin/sh
set -e

BIND=`ip r | grep $CONSUL_BIND | awk '{print $NF;exit}'`
echo $BIND

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use CONSUL_LOCAL_CONFIG
# below.
CONSUL_DATA_DIR=/var/consul
CONSUL_CONFIG_DIR=/etc/consul


exec /usr/local/bin/consul agent \
    -data-dir="$CONSUL_DATA_DIR" \
    -config-dir="$CONSUL_CONFIG_DIR" \
    -datacenter ${DATACENTER} \
    -bind ${BIND} \
    -rejoin \
    -retry-join $CONSUL \
    -retry-interval 10s
