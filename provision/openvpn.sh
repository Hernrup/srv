#!/usr/bin/env bash
set -e

sudo apt install openvpn
# git clone https://github.com/masterkorp/openvpn-update-resolv-conf ~/.build/openvpn-update-resolv-conf
# cp ~/.build/openvpn-update-resolv-conf/update-resolv-conf.sh /usr/local/bin/

# add the following lines to the ovpn config file manualy if you dont have an existing file
#script-security 2
#up /home/mhe/src/openvpn-update-resolv-conf/update-resolv-conf.sh
#down /home/mhe/src/openvpn-update-resolv-conf/update-resolv-conf.sh
