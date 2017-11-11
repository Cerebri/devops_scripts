#!/usr/bin/env bash

#
# Please note this script must be run pre-installation on the Ambari node to add the necessary services and repos to yum
# Typically it will be run by the Cloudbreak deployer
#

cd /tmp

# Get scripts
sudo yum install git -y
git clone https://github.com/Cerebri/devops_scripts.git
cd devops_scripts

# Install Java and Anaconda
#sudo ./CENTOS_Scripts/centos_install_java.sh

# Install Cassandra & ELK service and Datastax repo
sudo bash ./HDP_Scripts/ambari_install_elk_service.sh
sudo bash ./HDP_Scripts/ambari_install_cassandra_service.sh
sudo bash ./HDP_Scripts/ambari_install_postgres_service.sh
sudo bash ./HDP_Scripts/hdp_install_repos.sh
sudo bash ./HDP_Scripts/recipes/post_anaconda.sh
sudo bash ./HDP_Scripts/recipes/post_file_mapping.sh
