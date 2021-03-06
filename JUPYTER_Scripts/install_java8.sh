#!/usr/bin/env bash

## install java8
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:webupd8team/java -y 
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java8-installer -y

sudo echo 'export JAVA_HOME="/usr/lib/jvm/java-8-oracle"' >> /etc/profile
sudo echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile

exit 0