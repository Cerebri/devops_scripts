#!/usr/bin/env bash

function print_green {
  echo -e "\e[32m${1}\e[0m"
}

print_green 'Cleanup old kernals'
package-cleanup --oldkernels --count=1 -y

print_green 'Remove the traces of the template MAC address and UUIDs'
sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-eth0

print_green 'Cleaning YUM'
yum clean all

print_green 'Cleaning logs'
service rsyslog stop
service auditd stop
logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
rm -rf /var/log/anaconda
find /var/log -type f | while read f; do echo -ne '' > $f; done

print_green 'Clean /tmp'
rm -rf /tmp/*
rm -rf /var/tmp/*

print_green 'Remove SSH keys'
[ -f /home/centos/.ssh/authorized_keys ] && rm -f /home/centos/.ssh/authorized_keys
rm -f /etc/ssh/*key*

print_green 'Cleanup bash and SSH history'
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/centos/.bash_history ] && rm /home/centos/.bash_history
rm -rf ~root/.ssh/
rm -f ~root/anaconda-ks.cfg

