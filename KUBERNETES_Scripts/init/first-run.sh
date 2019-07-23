#!/usr/bin/env bash

#Fix DNS, call with the FQDN as $1 and make sure to run as sudo
DOMAINNAME=$1
sudo sed -i "s/reddog.microsoft.com/${DOMAINNAME}/" /etc/resolv.conf
#sudo -i
echo "search ${DOMAINNAME}" > /etc/resolvconf/resolv.conf.d/base
#exit

sudo apt-get update

#Fix permissions
sudo chown -R cerebri:cerebri /home/cerebri

# Install helm (as cerebri user)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
helm init --upgrade

# Add elastic helm repo
helm repo add elastic https://helm.elastic.co

helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/

#Install docker
#apt install docker.io -y

#Install Java
sudo apt-get install default-jdk -y
# Now proceed to add to Jenkins
