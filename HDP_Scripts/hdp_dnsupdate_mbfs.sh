#!/usr/bin/env bash

DOMAIN="mbfs.cerebri.internal"
LINE="SEARCH=${DOMAIN}"
FILE=/etc/sysconfig/network
grep -q "$LINE" "$FILE" || echo -e "\n$LINE" >> "$FILE"
LINE="DOMAIN=${DOMAIN}"
grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
find /etc -type f -exec sed -i -e "s/example.com/${DOMAIN}/" {} \;
find /srv -type f -exec sed -i -e "s/example.com/${DOMAIN}/" {} \;
systemctl restart salt-api.service
systemctl restart salt-bootstrap.service
systemctl restart salt-master.service
systemctl restart salt-minion.service
systemctl restart ambari-server.service
systemctl restart ambari-agent.service

# cat a here-doc represenation of the hooks to the appropriate file
cat > /etc/dhcp/dhclient-exit-hooks <<"EOF"
#!/bin/bash
printf "\ndhclient-exit-hooks running...\n\treason:%s\n\tinterface:%s\n" "${reason:?}" "${interface:?}"
# only execute on the primary nic
if [ "$interface" != "eth0" ]
then
    exit 0;
fi
# when we have a new IP, perform nsupdate
if [ "$reason" = BOUND ] || [ "$reason" = RENEW ] ||
   [ "$reason" = REBIND ] || [ "$reason" = REBOOT ] || [ "$reason" = PREINIT ]
then
    printf "\tnew_ip_address:%s\n" "${new_ip_address:?}"
    host=$(hostname | cut -d'.' -f1)
    domain=$(hostname -f | cut -d'.' -f2- -s)
    domain=${domain:='cerebri.internal'} # If no hostname is provided, use cdh-cluster.internal
    IFS='.' read -ra ipparts <<< "$new_ip_address"
    ptrrec="${ipparts[3]}.${ipparts[2]}.${ipparts[1]}.${ipparts[0]}.in-addr.arpa"
    nsupdatecmds=$(mktemp -t nsupdate.XXXXXXXXXX)
    #resolvconfupdate=$(mktemp -t resolvconfupdate.XXXXXXXXXX)
    #echo updating resolv.conf
    #grep -iv "search" /etc/resolv.conf > "$resolvconfupdate"
    #echo "search $domain" >> "$resolvconfupdate"
    #cat "$resolvconfupdate" > /etc/resolv.conf
    echo "Attempting to register $host.$domain and $ptrrec"
    {
        echo "update delete $host.$domain a"
        echo "update add $host.$domain 600 a $new_ip_address"
        echo "send"
        echo "update delete $ptrrec ptr"
        echo "update add $ptrrec 600 ptr $host.$domain"
        echo "send"
    } > "$nsupdatecmds"
    nsupdate "$nsupdatecmds"
fi
#done
exit 0;
EOF
chmod 755 /etc/dhcp/dhclient-exit-hooks
cp /etc/dhcp/dhclient-exit-hooks /etc/NetworkManager/dispatcher.d/12-register-dns
systemctl restart network.service