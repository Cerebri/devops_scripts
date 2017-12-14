#!/usr/bin/env bash

## add the main azure dns server to resolvconf
sudo echo 'nameserver 10.1.0.5' >> /etc/resolvconf/resolv.conf.d/head
sudo resolvconf -u 

exit 0