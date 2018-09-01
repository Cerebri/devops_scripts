#!/usr/bin/env bash

fdisk /dev/sdc
# Create new partition then set type to "8e"

pvcreate /dev/sdc1

vgextend rootvg /dev/sdc1

lvextend /dev/rootvg/rootlv /dev/sdc1

resize2fs /dev/rootvg/rootlv

df -h

yum install hyperv-tools.noarch -y

reboot