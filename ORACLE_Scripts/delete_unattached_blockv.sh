#!/usr/bin/env bash

COMPARTMENTS=$(oci iam compartment list --compartment-id-in-subtree true | jq -r '.data[] |.id')

for compartment in ${COMPARTMENTS[*]}
do
   compartment_name=$(oci iam compartment get --compartment-id ${compartment} | jq -r '.data."name"')
   echo ${compartment_name}
   VOLUME_LIST=$(oci bv volume list -c ${compartment} --all | jq -r '.data[] |.id')
   ATTACHED_VOLUMES=$(oci compute volume-attachment list -c ${compartment} --all | jq -r '.data[] |."volume-id"')
   for volume in ${VOLUME_LIST[*]}
   do
      #if exists_in_list ${ATTACHED_VOLUMES} ${volume}; then
      #volume_name=$(oci bv volume get --volume-id ${volume} | jq -r '.data."display-name"')
      if [[ "${ATTACHED_VOLUMES}" =~  ${volume} ]]; then
         echo "- ${volume} is attached."
      else
         echo "- ${volume} is NOT attached, deleting."
         #oci bv volume delete --volume-id ${volume} --force
      fi
      #oci bv boot-volume-backup delete --boot-volume-backup-id ${backup} --force --wait-for-state TERMINATED --max-wait-seconds 24000
   done
done
