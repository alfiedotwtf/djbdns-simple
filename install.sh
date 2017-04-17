#!/bin/bash

###
### CONFIG OPTIONS
###

SERVERUSER=gtinydns
SERVERLOGUSER=gdnslog

# uncomment if the first address found is not your DNS server address
#SERVERIP=<insert your dns server IP address>
SERVERIP=`ip addr | grep 'inet ' | grep -v 127.0.0.1 | perl -pe 's/.*inet ([^\/]+).*/$1/'`

###############################################################################
###############################################################################
###############################################################################

if [ -z $SERVERIP ]; then
  echo "error: could not find your dns server IP address"
fi

if [ -z "$(which svc)" ]; then
  echo "error: daemontools needs to be installed first"
  exit 1
fi

if [ -z "$(which cc)" ]; then
  echo "error: cc needs to be installed first"
  exit 1
fi

if [ -z "$(which make)" ]; then
  echo "error: make needs to be installed first"
  exit 1
fi

echo gcc -O2 -include /usr/include/errno.h > djbdns-1.05/conf-cc

make -C djbdns-1.05 && make -C djbdns-1.05 setup check

if [ ! -f /usr/local/bin/tinydns ]; then
  echo "error: make install failed"
  exit 1
fi

adduser --no-create-home -disabled-password --disabled-login $SERVERUSER
adduser --no-create-home -disabled-password --disabled-login $SERVERLOGUSER

mkdir -p /service

if [ ! -d /etc/tinydns ]; then
  tinydns-conf $SERVERUSER $SERVERLOGUSER /etc/tinydns $SERVERIP
fi

if [ ! -d /service/tinydns ]; then
  mkdir -p /service
  ln -s /etc/tinydns /service/tinydns
fi
