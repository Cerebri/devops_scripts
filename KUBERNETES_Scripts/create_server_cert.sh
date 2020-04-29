#!/usr/bin/env bash

# According to these instructions: https://serverfault.com/questions/845766/generating-a-self-signed-cert-with-openssl-that-works-in-chrome-58
# server_rootCA.pem, server_rootCA.key is the root CA for *.cerebri.internal, you know where to get it ;-)

# Call with the FQDN of the required cert, i.e. dev.hub.cerebri.internal
FQDN="${1}"

echo "[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=US
ST=Texas
L=Austin
O=CerebriAI
OU=DevOps
emailAddress=nic@cerebriai.com
CN = ${FQDN}" > ${FQDN}.csr.cnf

echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${FQDN}" > ${FQDN}.v3.ext

# Create server key
openssl req -new -sha256 -nodes -out ${FQDN}.csr -newkey rsa:2048 -keyout ${FQDN}.key -config <( cat ${FQDN}.csr.cnf )

# Create server cert
openssl x509 -req -in ${FQDN}.csr -CA server_rootCA.pem -CAkey server_rootCA.key -CAcreateserial -out ${FQDN}.crt -days 3650 -sha256 -extfile ${FQDN}.v3.ext

# Cleaning up
rm -rf ./${FQDN}.csr.cnf
rm -rf ./${FQDN}.v3.ext
rm -rf ./${FQDN}.csr