#!/usr/bin/env bash

# Master Client Resource Group and Network, location
ClientRG= #######
Location="westeurope"
ClientVnet="$(echo "${ClientRG}" | tr '[:upper:]' '[:lower:]')Vnet"
# Pre-create this subnet in the vNet, at least /21
AKSSubnetName=""
# Log Analytics Workspace ID
LogAnalyticsWorkspaceID=""
# Cluster Type, i.e. Development, LaunchPipe or Launch
ClusterType="Development"

# Install aks-preview
az extension add --name aks-preview
az extension update --name aks-preview

# Create Service Principal for this aks
az ad sp create-for-rbac --skip-assignment --name "k8s${ClientRG}{ClusterType}" > secrets.txt
AppID=$(cat secrets.txt | grep appId | awk '{ print substr($2, 1, length($2)-1) }')
AppPassword=$(cat secrets.txt | grep password | awk '{ print substr($2, 1, length($2)-1) }')
rm -rf ./secrets.txt
# Get vNet and Subnet
VNET_ID=$(az network vnet show --resource-group ${ClientRG} --name ${ClientVnet} --query id -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group ${ClientRG} --vnet-name ${ClientVnet} --name ${AKSSubnetName} --query id -o tsv)
# Add SP as Contributor on vNet
az role assignment create --assignee ${AppID} --scope ${VNET_ID} --role Contributor

az aks create \
    --name "${ClientRG}k8s${ClusterType}" \
    --resource-group ${ClientRG} \
    --service-principal ${AppID} \
    --client-secret ${AppPassword} \
    --node-resource-group "${ClientRG}k8s${ClusterType}" \
    --location ${Location}
    --nodepool-name permpool \
    --node-count 2 \
    --node-vm-size Standard_E8s_v3 \
    --max-pods 50 \
    --network-plugin azure \
    --enable-private-cluster \
    --admin-username kubeuser \
    --vnet-subnet-id ${SUBNET_ID} \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.240.0.10 \
    --service-cidr 10.240.0.0/16 \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku standard \
    --enable-addons monitoring \
    --workspace-resource-id ${LogAnalyticsWorkspaceID}
    --generate-ssh-keys

az aks nodepool add \
    --resource-group ${ClientRG} \
    --cluster-name myAKSCluster \
    --name lowpool \
    --node-count 3 \
    --node-vm-size Standard_E4s_v3 \
    --priority Low \
    --vnet-subnet-id ${SUBNET_ID} \
    --enable-cluster-autoscaler \
    --min-count 3 \
    --max-count 20
