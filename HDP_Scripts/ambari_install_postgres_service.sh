#!/usr/bin/env bash

mkdir -p /var/lib/ambari-server/resources/stacks/HDP/2.6/services/

git clone https://github.com/Cerebri/ambari-postgres-service.git /var/lib/ambari-server/resources/stacks/HDP/2.6/services/POSTGRES

service ambari-server stop

sleep 15

service ambari-server start