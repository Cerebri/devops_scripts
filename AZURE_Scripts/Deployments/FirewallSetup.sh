#!/usr/bin/env bash

# Custom Script for Linux

if [ ! -e "/cf/conf/mutex.config" ]; then
	sed -i '.bak' -e 's#<hostname>pfsense</hostname>#<hostname>'"$1"'</hostname>#g' /cf/conf/config.xml
	sed -i '.bak2' -e 's/10\.15/'"$2"'/g' /cf/conf/config.xml
	rm /tmp/config.cache
	rm /cf/conf/trigger_initial_wizard
	touch /cf/conf/mutex.config
	shutdown -r +20sec "System will reboot"
	exit 0
else
	exit 0
fi