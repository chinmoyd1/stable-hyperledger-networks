#!/bin/sh
# This is a comment!

rm -rf channel-artifacts/* crypto-config/*

echo
echo "#################################################################"
echo "#######         Generating Crypto Material             ##########"
echo "#################################################################"
export FABRIC_CFG_PATH=$PWD
set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######          Generating Genesis Block              ##########"
echo "#################################################################"
set -x
  configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
  res=$?
set +x
if [ $res -ne 0 ]; then
    echo "Failed to generate Genesis Block..."
    exit 1
fi

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
set -x
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
  res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for Org1MSP   ##########"
echo "#################################################################"
set -x
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
  res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for Org2MSP   ##########"
echo "#################################################################"
set -x
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP
  res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######           Strating the Network                 ##########"
echo "#################################################################"
export IMAGE_TAG=latest
docker-compose up -d 2>&1
sleep 1
docker ps -a
if [ $? -ne 0 ]; then
  echo "ERROR !!!! Unable to start network"
  exit 1
fi

sleep 2
echo
echo "#################################################################"
echo "#######         End to End testing the network         ##########"
echo "#################################################################"
echo
docker exec cli scripts/script.sh
if [ $? -ne 0 ]; then
    echo "ERROR !!!! Test failed"
    exit 1
fi