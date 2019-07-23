#!/usr/bin/env bash

# Run this with the prefix used in create-ns.sh

NAMESPACE="${1}"



server=$(kubectl cluster-info | grep master | awk '{ print $6 }' | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g')
cluster=$(kubectl config get-clusters | grep -v NAME)
# Default toke name
name_default=$(kubectl get secret -n default -o name | grep default-token)
# Server Certificate, same for all tokens
ca=$(kubectl get $name_default -n default -o jsonpath='{.data.ca\.crt}')
# Start config creation
echo "apiVersion: v1
kind: Config

# Define the cluster
clusters:
- name: ${cluster}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
" > ns.config

# Add user
echo "users:" >> ns.config
echo "Adding service accounts for namespace: ${NAMESPACE}"
name=$(kubectl get secret -n ${NAMESPACE} -o name | grep ${NAMESPACE})
token=$(kubectl get $name -n ${NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)
echo "- name: ${NAMESPACE}-sa
  user:
    as-user-extra: {}
    client-key-data: ${ca}
    token: ${token}
" >> ns.config

# Start writing contexts linking cluster to user
echo "contexts:" >> ns.config
echo "Adding contexts for namespace: ${NAMESPACE}"
echo "- name: ${NAMESPACE}
  context:
    cluster: ${cluster}
    namespace: ${NAMESPACE}
    user: ${NAMESPACE}-sa
" >> ns.config

# Define current context
echo "current-context: ${NAMESPACE}" >> ns.config