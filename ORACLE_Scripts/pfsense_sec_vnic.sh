#!/usr/bin/env bash
if [ ! -e "/cf/conf/mutex.config" ]; then
  declare -r CURL=$(which curl)
  declare -r MD_URL='http://169.254.169.254/opc/v1/vnics/'
  declare -r tmpfile=$(mktemp /tmp/oci_vcn_md.XXXXX)
  declare -a MD_ADDRS
  $CURL -s $MD_URL | tr , '\n' >"$tmpfile"
  MD_ADDRS=($(grep -w privateIp "$tmpfile" | cut -f 4 -d '"')) # string
  for s in $(grep -w subnetCidrBlock "$tmpfile" | cut -f 4 -d '"'); do # string
      MD_SCIDRS+=(${s})
      MD_SPREFIXS+=(${s%/*})
      MD_SBITSS+=(${s#*/})
  done
  declare -r ip_address=${MD_ADDRS[1]}
  sed -i -e "s#<ipaddr>LAN_IP_ADDRESS</ipaddr>#<ipaddr>${ip_address}</ipaddr>#g" /cf/conf/config.xml
  declare -r ip_mask=${MD_SBITSS[1]}
  sed -i -e "s#<subnet>LAN_MASK</subnet>#<subnet>${ip_mask}</subnet>#g" /cf/conf/config.xml
  rm "$tmpfile"
  touch /cf/conf/mutex.config
  /etc/rc.reboot
	exit 0
else
	exit 0
fi
