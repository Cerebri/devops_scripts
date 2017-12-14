#!/usr/bin/env bash

## install java8
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:webupd8team/java -y 
sudo apt-get update
sudo apt-get install oracle-java8-installer -y

sudo echo 'export JAVA_HOME="/usr/bin/java"' >> /etc/profile
sudo echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile

exit 0