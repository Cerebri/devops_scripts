#!/usr/bin/env bash

mkdir -p /var/lib/ambari-server/resources/stacks/HDP/2.6/services/

git clone https://github.com/Cerebri/ambari-cassandra-service.git /var/lib/ambari-server/resources/stacks/HDP/2.6/services/CASSANDRA

service ambari-server stop

sleep 15

service ambari-server start