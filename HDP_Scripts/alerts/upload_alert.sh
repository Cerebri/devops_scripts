#!/usr/bin/env bash

# Call function with admin password, ambari IP and clustername

AMBARI_HOST=$2

curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @allocated_memory.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/$3/alert_definitions
curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @pending_apps.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/$3/alert_definitions
curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @pending_containers.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/$3/alert_definitions