#!/usr/bin/env bash

# Call function with admin password

AMBARI_HOST=localhost

curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @allocated_memory.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/autoscaling/alert_definitions
curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @pending_apps.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/autoscaling/alert_definitions
curl -u admin:${1} -i -k -H 'X-Requested-By:ambari' -X POST -d @pending_containers.json  https://${AMBARI_HOST}/ambari/api/v1/clusters/autoscaling/alert_definitions