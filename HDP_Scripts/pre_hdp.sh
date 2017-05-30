#!/usr/bin/env bash

cd /tmp

# Get scripts
yum install git -y
git clone https://github.com/Cerebri/devops_scripts.git
chmod -R u+x *.sh

# Install Java and Anaconda
./CENTOS_Scripts/centos_install_java.sh
./CENTOS_Scripts/centos_install_anaconda.sh

# Install Datastax repo
./HDP_Scripts/hdp_install_datastax_repo.sh