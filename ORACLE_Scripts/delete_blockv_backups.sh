#!/usr/bin/env bash

COMPARTMENTS=$(oci iam compartment list --compartment-id-in-subtree true | jq -r '.data[] |.id')

for compartment in ${COMPARTMENTS[*]}
do
   echo ${compartment}
   BACKUP_LIST=$(oci bv backup list -c ${compartment} --all | jq -r '.data[] |.id')
   for backup in ${BACKUP_LIST[*]}
   do
      echo "  ${backup}"
      oci bv backup delete --volume-backup-id ${backup} --force --wait-for-state TERMINATED --max-wait-seconds 24000
   done
done
