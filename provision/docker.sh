#!/usr/bin/env bash
set -e

echo 'install docker'
sudo apt-get remove docker docker-engine docker.io -y

sudo apt-get install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual -y

# docker
sudo apt install docker-ce -y

