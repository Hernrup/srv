#!/usr/bin/env bash
set -e

# Needed for Vim8 with good compile flags
sudo add-apt-repository ppa:pi-rho/dev -y

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) edge"

sudo apt update
