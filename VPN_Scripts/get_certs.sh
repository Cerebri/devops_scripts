#!/usr/bin/env bash

# Call the script with the host public FQDN

systemctl stop openvpnas.service

##Let's Encrypt Client Runs Here in standalone mode##
certbot renew

/usr/local/openvpn_as/scripts/confdba -mk cs.ca_bundle -v "`cat /etc/letsencrypt/live/${1}/fullchain.pem`"

/usr/local/openvpn_as/scripts/confdba -mk cs.priv_key -v "`cat /etc/letsencrypt/live/${1}/privkey.pem`" > /dev/null

/usr/local/openvpn_as/scripts/confdba -mk cs.cert -v "`cat /etc/letsencrypt/live/${1}/cert.pem`"

systemctl start openvpnas.service