#!/usr/bin/env bash

rm /cf/conf/mutex.config

ip_address="192.168.1.200"
ip_mask="24"

sed -i -e "s#<ipaddr>${ip_address}</ipaddr>#<ipaddr>LAN_IP_ADDRESS</ipaddr>#g" /cf/conf/config.xml
sed -i -e "s#<subnet>${ip_mask}</subnet>#<subnet>LAN_MASK</subnet>#g" /cf/conf/config.xml