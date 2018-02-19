#!/usr/bin/env bash
set -e

echo "install misc apps"
sudo apt install silversearcher-ag -y

echo "install python stuff"
sudo apt install python3 python3-pip build-essential cmake python-dev python3-dev -y
