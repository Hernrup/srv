#!/usr/bin/env bash
set -e
sudo apt install cifs-utils -y

sudo cp /etc/smb.conf /etc/smb.conf.bak
sudo ln -s -f smb.conf /etc/smb.conf
