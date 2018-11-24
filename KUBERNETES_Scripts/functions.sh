#!/usr/bin/env bash

# Include these functions in your .bashrc or source them before using

function kubectlns() {

  # Call this function with "kubectlns <namespace>"
  ctx=`kubectl config current-context`
  ns=$1

  # verify that the namespace exists
  ns=`kubectl get namespace $1 --no-headers --output=go-template={{.metadata.name}} 2>/dev/null`
  if [ -z "${ns}" ]; then
    echo "Namespace (${1}) not found, creating it."
    kubectl create namespace ${1}
    ns=$1
  fi

  kubectl config set-context ${ctx} --namespace="${ns}"
}