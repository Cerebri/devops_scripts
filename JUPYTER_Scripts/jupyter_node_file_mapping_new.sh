#!/usr/bin/env bash

# Storage Account ID
export ACCOUNT_ID=$1
# Storage Account key
export ACCOUNT_KEY=$2
# Storage Account ID for sandbox1
export ACCOUNT_NEW=$3
#Storage Account key for sandbox1
export ACCOUNT_PW=$4

apt-get install samba-client samba-common cifs-utils -y

mkdir -p /data
mkdir -p /scratch
mkdir -p /jupyter-notebooks


mkdir -p /data_SB1
mkdir -p /scratch_SB1
mkdir -p /jupyter-notebooks_SB1

# Mount directories here
mount -t cifs //$ACCOUNT_ID.file.core.windows.net/sftpdata /data -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev
echo "//$ACCOUNT_ID.file.core.windows.net/sftpdata    /data    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev 0 0" >> /etc/fstab

mount -t cifs //$ACCOUNT_ID.file.core.windows.net/scratch /scratch -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
echo "//$ACCOUNT_ID.file.core.windows.net/scratch    /scratch    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

mount -t cifs //$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks /jupyter-notebooks -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
echo "//$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks    /jupyter-notebooks    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

mount -t cifs //$ACCOUNT_NEW.file.core.windows.net/sftpdata /data_SB1 -o vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0555,file_mode=0444,uid=dev,gid=dev
echo "//$ACCOUNT_NEW.file.core.windows.net/sftpdata    /data_SB1    cifs    vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0555,file_mode=0444,uid=dev,gid=dev 0 0" >> /etc/fstab

mount -t cifs //$ACCOUNT_NEW.file.core.windows.net/scratch /scratch_SB1 -o vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
echo "//$ACCOUNT_NEW.file.core.windows.net/scratch    /scratch_SB1    cifs    vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

mount -t cifs //$ACCOUNT_NEW.file.core.windows.net/jupyter-notebooks /jupyter-notebooks_SB1 -o vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
echo "//$ACCOUNT_NEW.file.core.windows.net/jupyter-notebooks    /jupyter-notebooks_SB1    cifs    vers=3.0,username=$ACCOUNT_NEW,password=$ACCOUNT_PW,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab




exit 0
