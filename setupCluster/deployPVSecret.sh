#!/bin/bash +x

export STORAGE_ACCT_NAME=CHANGEME

#Check for kubectl

#Get Key from Storage Account
export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCT_NAME -o json --query [1].value | tr -d '"')

#Set Secret
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$STORAGE_ACCT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY