#!/bin/bash +x

CHANNEL_NAME=$1
: ${CHANNEL_NAME:="mychannel"}

export TOOLS=$PWD/../bin
export CONFIG_PATH=$PWD
export FABRIC_CFG_PATH=$PWD
export STORAGE_ACCT_NAME=CHANGEME
export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCT_NAME -o json --query [1].value | tr -d '"')
export ORG1_SHARE_NAME=org1
export ORG2_SHARE_NAME=org2
export ORDERORG_SHARE_NAME=orgorderer1
export ARTIFACTS_SHARE_NAME=channel-artifacts

## Generates Org certs
function generateCerts (){
	CRYPTOGEN=$TOOLS/cryptogen

	$CRYPTOGEN generate --config=./cluster-config.yaml	
	

}

function generateChannelArtifacts() {
	if [ ! -d channel-artifacts ]; then
		mkdir channel-artifacts
	fi


	CONFIGTXGEN=$TOOLS/configtxgen
 	$CONFIGTXGEN -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
#	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
	
	chmod -R 777 ./channel-artifacts && chmod -R 777 ./crypto-config

	cp ./channel-artifacts/genesis.block ./crypto-config/ordererOrganizations/*

	cp -r ./crypto-config ./opt/share/ && cp -r ./channel-artifacts ./opt/share/
	
	az storage file upload-batch -s ./opt/share/crypto-config/ordererOrganizations/orgorderer1/ -d $ORDERORG_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY --max-connections 50
	az storage file upload-batch -s ./opt/share/crypto-config/peerOrganizations/org1 -d $ORG1_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY --max-connections 50
	az storage file upload-batch -s ./opt/share/crypto-config/peerOrganizations/org2 -d $ORG2_SHARE_NAME --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY --max-connections 50
	
	az storage file upload -s $ARTIFACTS_SHARE_NAME --source ./channel-artifacts/genesis.block --account-name $STORAGE_ACCT_NAME --account-key $STORAGE_KEY

	#./opt/share is a logical local directory to stage files. 
	#Files are then copied to two Azure shares
}

function generateK8sYaml (){
	python3.5 transform/generate.py
}

function clean () {
	rm -rf ./opt/share/crypto-config/*
	rm -rf crypto-config
}




## Genrates orderer genesis block, channel configuration transaction and anchor peer upddate transactions
##function generateChannelArtifacts () {
##	CONFIGTXGEN=$TOOLS/configtxgen
	
#}

clean
generateCerts
generateChannelArtifacts
generateK8sYaml
