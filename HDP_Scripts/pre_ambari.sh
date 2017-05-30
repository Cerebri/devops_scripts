#!/usr/bin/env bash

cd /tmp

# Get scripts
yum install git -y
git clone https://github.com/Cerebri/devops_scripts.git
cd devops_scripts
chmod -R -v u+x ./*

# Install Java and Anaconda
sudo ./CENTOS_Scripts/centos_install_java.sh
sudo ./CENTOS_Scripts/centos_install_anaconda.sh

# Install Cassandra service and Datastax repo
sudo ./HDP_Scripts/ambari_install_cassandra_service.sh
sudo ./HDP_Scripts/hdp_install_datastax_repo.sh