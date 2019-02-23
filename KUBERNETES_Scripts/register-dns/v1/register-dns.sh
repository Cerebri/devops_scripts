#!/usr/bin/env bash

# Change the reddog.microsoft.com to Custom Domain

DOMAINNAME=$1

echo $(date) " - Starting Script"

sed -i .bak 's/reddog.microsoft.com/${DOMAINNAME}/' /etc/resolv.conf

echo "search ${DOMAINNAME}" > /etc/resolvconf/resolv.conf.d/base