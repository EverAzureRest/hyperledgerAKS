#!/bin/bash +x


export STORAGE_ACCT_NAME=CHANGEME
export DEPLOYMENT_REGION=CHAMGEME
export RESOURCE_GROUP_NAME=CHANGEME
export AKS_CLUSTERNAME=CHANGEME
export ORG1_SHARE_NAME=org1
export ORG2_SHARE_NAME=org2
export ORDERORG_SHARE_NAME=orgorderer1
export ARTIFACTS_SHARE_NAME=channel-artifacts
#optional and only used if deploying into an existing VNET
#export SUBNET_NAME=
#optional and only used if deploying into an existing VNET
#export VNET_NAME=

buildRG () {
    az group create -n $RESOURCE_GROUP_NAME -l $DEPLOYMENT_REGION
}

buildStorage () {
    az storage account create -n $STORAGE_ACCT_NAME -l $DEPLOYMENT_REGION -g $RESOURCE_GROUP_NAME --sku Standard_LRS
    STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCT_NAME -o json --query [1].value | tr -d '"')
    az storage share create -n $ORG1_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY
    az storage share create -n $ORG2_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY
    az storage share create -n $ORDERORG_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY
    az storage share create -n $ARTIFACTS_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY
}

buildAKS () {
    if [ $SUBNET_NAME ]; then
    SUBNET_ID=$(az network vnet subnet show -n $SUBNET_NAME -g $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME --query id -o tsv)
    az aks create -n $AKS_CLUSTERNAME -g $RESOURCE_GROUP_NAME --network-plugin azure --vnet-subnet-id $SUBNET_ID
    fi 
    az aks create -n $AKS_CLUSTERNAME -g $RESOURCE_GROUP_NAME 
}

getCreds () {
    az aks get-credentials -n $AKS_CLUSTERNAME -g $RESOURCE_GROUP_NAME
}

buildRG
buildStorage
buildAKS
getCreds