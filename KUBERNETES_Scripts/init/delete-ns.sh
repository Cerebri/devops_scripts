#!/usr/bin/env bash

# Run this with the desired prefix, i.e. "datascience, sandbox, etc" doesn't matter if the namespaces already exist

NAME="${1}"
shift
ENV_LIST="${@}"

for ENV in $ENV_LIST; do
  echo "Creating namespace: ${NAME}-${ENV}"
  cat ns-create.yaml.tmpl | sed "s/NAME/${NAME}/g" | sed "s/ENV/${ENV}/g" | kubectl delete -f -
done
