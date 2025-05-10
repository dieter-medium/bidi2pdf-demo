#!/bin/bash
#

set -x


export OPENSSL_CONF=$(pwd)/openssl.conf

openssl genrsa -out domain.key 2048
openssl req -new -key domain.key -out domain.csr

# not all openssl subcommands respect the env var OPENSSL_CONF
openssl x509 -req -days 365 -in domain.csr -signkey domain.key -out domain.crt -extensions v3_req -extfile $OPENSSL_CONF
openssl x509 -in domain.crt -text -noout

cat domain.crt domain.key > domain.pem

sleep 5

exit 0
