#!/usr/bin/env bash

apt-get clean all

apt-get update

apt-get upgrade -y

apt-get dist-upgrade -y

apt-get autoremove -y