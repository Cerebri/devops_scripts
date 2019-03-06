#!/usr/bin/env bash

# Run this with the prefix used in create-ns.sh

NAME="${1}"

ENV_LIST="dev qa stage"

server=$(kubectl cluster-info | grep master | awk '{ print $6 }' | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g')
cluster=$(kubectl config get-clusters | grep -v NAME)
# Default toke name
name_default=$(kubectl get secret -n default -o jsonpath="{.items[].metadata.name}" | grep default-token)
# Server Certificate, same for all tokens
ca=$(kubectl get secret/$name_default -n default -o jsonpath='{.data.ca\.crt}')
# Start config creation
echo "apiVersion: v1
kind: Config
clusters:
- name: ${cluster}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:" > ns.config

# Start writing contexts
for ENV in $ENV_LIST; do
  echo "Adding contexts for namespace: ${NAME}-${ENV}"
  echo "- name: ${NAME}-${ENV}
  context:
    cluster: ${cluster}
    namespace: ${NAME}-${ENV}
    user: ${NAME}-${ENV}-sa" >> ns.config
done
echo "current-context: ${NAME}-dev" >> ns.config

# Add users
echo "users:" >> ns.config
for ENV in $ENV_LIST; do
  echo "Adding service accounts for namespace: ${NAME}-${ENV}"
  name=$(kubectl get secret -n ${NAME}-${ENV} -o jsonpath="{.items[].metadata.name}" | grep ${NAME}-${ENV}-sa-token)
  token=$(kubectl get secret/$name -n ${NAME}-${ENV} -o jsonpath='{.data.token}' | base64 -d)
  echo "- name: ${NAME}-${ENV}-sa
  user:
    token: ${token}" >> ns.config
done