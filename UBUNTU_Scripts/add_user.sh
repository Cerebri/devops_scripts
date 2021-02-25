#!/usr/bin/env bash

# ${1} is the new username
# ${2} is the Public Key

adduser --disabled-password --gecos "${1}" --force-badname ${1}

mkdir -p /home/${1}/.ssh
echo "${2}" > /home/${1}/.ssh/authorized_keys

chown -R ${1}:${1} /home/${1}/.ssh
chmod 0700 /home/${1}/.ssh
chmod 0600 /home/${1}/.ssh/authorized_keys

# SUDO rights
echo "${1} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/10-cerebri-sudo-users