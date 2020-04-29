#!/usr/bin/env bash

source $1

az aks get-credentials --resource-group ${ClientRG} --name "${ClientRG}k8s${ClusterType}"  --overwrite-existing --admin