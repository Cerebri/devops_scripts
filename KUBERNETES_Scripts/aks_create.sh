#!/usr/bin/env bash
set -x

source $1

az aks create \
    --name "${ClientRG}k8s${ClusterType}" \
    --resource-group ${ClientRG} \
    --node-resource-group "${ClientRG}k8s${ClusterType}" \
    --location ${Location} \
    --kubernetes-version "1.15.5" \
    --nodepool-name permpool \
    --node-count 2 \
    --node-vm-size Standard_E8s_v3 \
    --max-pods 50 \
    --network-plugin azure \
    --admin-username kubeuser \
    --vnet-subnet-id ${SUBNET_ID} \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.240.0.10 \
    --service-cidr 10.240.0.0/16 \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku standard \
    --enable-addons monitoring \
    --workspace-resource-id ${LogAnalyticsWorkspaceID} \
    --generate-ssh-keys

az aks nodepool add \
    --resource-group ${ClientRG} \
    --cluster-name "${ClientRG}k8s${ClusterType}" \
    --name lowpool \
    --node-count 3 \
    --node-vm-size Standard_E4s_v3 \
    --priority Low \
    --vnet-subnet-id ${SUBNET_ID} \
    --enable-cluster-autoscaler \
    --min-count 3 \
    --max-count 20
