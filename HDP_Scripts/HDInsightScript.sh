#!/usr/bin/env bash

echo $1  # Storage Account ID
echo $2  # Storage Account key

if [[ ! -d "/data" ]]; then

	mkdir -p /data
	mkdir -p /scratch

	# Mount directories here
	mount -t cifs //$1.file.core.windows.net/sftpdata /data -o vers=3.0,username=$1,password=$2,dir_mode=0555,file_mode=0444,uid=testuser,gid=testuser
	echo "//$1.file.core.windows.net/sftpdata    /data    cifs    vers=3.0,username=$1,password=$2,dir_mode=0555,file_mode=0444,uid=testuser,gid=testuser 0 0" >> /etc/fstab

	mount -t cifs //$1.file.core.windows.net/scratch /scratch -o vers=3.0,username=$1,password=$2,dir_mode=0777,file_mode=0777,uid=testuser,gid=testuser
	echo "//$1.file.core.windows.net/scratch    /scratch    cifs    vers=3.0,username=$1,password=$2,dir_mode=0777,file_mode=0777,uid=testuser,gid=testuser 0 0" >> /etc/fstab

fi