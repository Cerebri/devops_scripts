#!/usr/bin/env bash

yum -y install epel-release
yum -y install java-1.8.0-openjdk-devel
yum -y install salt-master salt-api salt-minion
yum -y install krb5-server krb5-libs krb5-workstation
yum -y install snappy-devel
yum -y install unzip curl wget git bind-utils ntp tmux bash-completion nginx haveged
yum -y install ambari-server ambari-agent
