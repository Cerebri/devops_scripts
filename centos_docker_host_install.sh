#!/bin/bash

# Script to set up Docker Host on LVM and install docker-compose
#
# This script take two parameters:
#  1 - the device where the LVM partition should go, example /dev/xvdf
#  2 - The maximum size of docker containers disk, docker by default makes this 10GB which may be too small for some applications.

yum update -y

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install docker-engine lvm2 git -y

systemctl enable docker.service

systemctl start docker
systemctl stop docker
rm -rf /var/lib/docker

pvcreate $1
vgcreate docker $1
lvcreate --wipesignatures y -n thinpool docker -l 95%VG
lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG

lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

tee /etc/lvm/profile/docker-thinpool.profile <<-'EOF'
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF

lvchange --metadataprofile docker-thinpool docker/thinpool
lvs -o+seg_monitor

touch /etc/docker/daemon.json
tee /etc/docker/daemon.json <<-'EOF'
{
  "storage-driver": "devicemapper",
   "storage-opts": [
     "dm.thinpooldev=/dev/mapper/docker-thinpool",
     "dm.use_deferred_removal=true",
     "dm.use_deferred_deletion=true",
     "dm.basesize=$2"
   ]
}
EOF

systemctl daemon-reload

systemctl start docker

curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
