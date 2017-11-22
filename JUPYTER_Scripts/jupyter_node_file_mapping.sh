#!/usr/bin/env bash
 # Storage Account ID
export ACCOUNT_ID=$1
  # Storage Account key
export ACCOUNT_KEY=$2

if [[ ! -d "/data" ]]; then
    apt-get install samba-client samba-common cifs-utils -y
	mkdir -p /data
	mkdir -p /scratch
	mkdir -p /jupyter-notebooks

	# Mount directories here
	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/sftpdata /data -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/sftpdata    /data    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev 0 0" >> /etc/fstab

	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/scratch /scratch -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/scratch    /scratch    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks /jupyter-notebooks -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks    /jupyter-notebooks    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

fi