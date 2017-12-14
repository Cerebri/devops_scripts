#!/usr/bin/env bash

## Script for installing HDFS client

export AMBARI_USER=$1
export PASSWORD=$2
export AMBARI_URL=$3
export HDP_NAME=$4

sudo mkdir -p /etc/hadoop/conf
cd /tmp

curl --user $AMBARI_USER:$PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_URL:8080/api/v1/clusters/$HDP_NAME/services/HDFS/components/HDFS_CLIENT?format=client_config_tar -o configs.tar.gz
sudo tar xvzf configs.tar.gz -C /etc/hadoop/conf
sudo awk '{ gsub(/export JAVA_HOME=\/usr\/lib\/jvm\/java/, "export JAVA_HOME=/usr"); print }' /etc/hadoop/conf/hadoop-env.sh > /etc/hadoop/conf/new-hadoop-env.sh
sudo mv /etc/hadoop/conf/new-hadoop-env.sh /etc/hadoop/conf/hadoop-env.sh


## needs to go in /etc/apt/sources.list.d/
wget http://public-repo-1.hortonworks.com/HDP/ubuntu16/2.x/updates/2.6.3.0/hdp.list
sudo cp hdp.list /etc/apt/sources.list.d/
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B9733A7A07513CAD
sudo apt-get update
sudo apt-get install hadoop-hdfs -y

exit 0