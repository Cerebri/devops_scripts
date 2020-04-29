#!/usr/bin/env bash

ClientRG="####"
Location="###"
ClientVnet="###"
AKSSubnetName="###"
LogAnalyticsWorkspaceID="####"
ClusterType="Development"
VNET_ID=$(az network vnet show --resource-group ${ClientRG} --name ${ClientVnet} --query id -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group ${ClientRG} --vnet-name ${ClientVnet} --name ${AKSSubnetName} --query id -o tsv)