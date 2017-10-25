#!/usr/bin/env bash

echo $1  # Storage Account ID
echo $2  # Storage Account key
echo $3  # Local User AND Group to mount as
export share="zeppelin/user/notebook"

if [[ ! -d "/azure_notebooks" ]]; then

	mkdir -p /azure_notebooks

	# Mount directories here
	mount -t cifs //$1.file.core.windows.net/$share /azure_notebooks -o vers=3.0,username=$1,password=$2,dir_mode=0555,file_mode=0444,uid=$3,gid=$3
	echo "//$1.file.core.windows.net/$share    /azure_notebooks    cifs    vers=3.0,username=$1,password=$2,dir_mode=0555,file_mode=0444,uid=$3,gid=$3 0 0" >> /etc/fstab

fi