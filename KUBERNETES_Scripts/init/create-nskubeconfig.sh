#!/usr/bin/env bash

# Run this with the prefix used in create-ns.sh

NAME="${1}"
shift
ENV_LIST="${@}"

server=$(kubectl cluster-info | grep master | awk '{ print $6 }' | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g')
cluster=$(kubectl config get-clusters | grep -v NAME)
# Default toke name
#name_default=$(kubectl get secret -n default -o jsonpath="{.items[].metadata.name}" | grep default-token)
# Server Certificate, same for all tokens
#ca=$(kubectl get secret/$name_default -n default -o jsonpath='{.data.ca\.crt}')
# Start config creation
echo "apiVersion: v1
kind: Config

" > ${NAME}.config

# Add user
echo "users:" >> ${NAME}.config
for ENV in $ENV_LIST; do
  echo "Adding service accounts for namespace: ${NAME}-${ENV}"
  name_token=$(kubectl describe sa ${NAME}-${ENV}-sa -n ${NAME}-${ENV} | grep Tokens | awk '{print $2}')
  token=$(kubectl get secret/$name_token -n ${NAME}-${ENV} -o jsonpath='{.data.token}' | base64 -d)
  ca=$(kubectl get secret/$name_token -n ${NAME}-${ENV} -o "jsonpath={.data['ca\.crt']}")
  echo "- name: ${NAME}-${ENV}-sa
  user:
    as-user-extra: {}
    client-key-data: ${ca}
    token: ${token}" >> ${NAME}.config
done

# Define the cluster
echo "
clusters:
- name: ${cluster}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
" >> ${NAME}.config

# Start writing contexts linking cluster to user
echo "contexts:" >> ${NAME}.config
for ENV in $ENV_LIST; do
  echo "Adding contexts for namespace: ${NAME}-${ENV}"
  echo "- name: ${NAME}-${ENV}
  context:
    cluster: ${cluster}
    namespace: ${NAME}-${ENV}
    user: ${NAME}-${ENV}-sa" >> ${NAME}.config
done

# Define current context
echo "current-context: ${NAME}-${ENV}" >> ${NAME}.config

