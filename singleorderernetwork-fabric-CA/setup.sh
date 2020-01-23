#!/bin/sh
# This is a comment!
export COMPOSE_PROJECT_NAME=catest

# rm -rf channel-artifacts/* crypto-config/*

# echo
# echo "#################################################################"
# echo "#######         Generating Crypto Material             ##########"
# echo "#################################################################"
# export FABRIC_CFG_PATH=$PWD
# set -x
#   cryptogen generate --config=./crypto-config.yaml
#   res=$?
# set +x
# if [ $res -ne 0 ]; then
#   echo "Failed to generate crypto material..."
#   exit 1
# fi

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

# replacePrivateKey

# echo
# echo "#################################################################"
# echo "## Populating environment variables with private key location  ##"
# echo "#################################################################"
# set -x
#   export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)
#   res=$?
# set +x
# if [ $res -ne 0 ]; then
#   echo "Failed to copy private key location of Org1..."
#   exit 1
# fi
# set -x
#   export BYFN_CA2_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org2.example.com/ca && ls *_sk)
#   res=$?
# set +x
# if [ $res -ne 0 ]; then
#   echo "Failed to copy private key location of Org2..."
#   exit 1
# fi

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


# function replacePrivateKey() {
#   # sed on MacOSX does not support -i flag with a null extension. We will use
#   # 't' for our back-up's extension and delete it at the end of the function
#   ARCH=$(uname -s | grep Darwin)
#   if [ "$ARCH" == "Darwin" ]; then
#     OPTS="-it"
#   else
#     OPTS="-i"
#   fi

#   # Copy the template to the file that will be modified to add the private key
#   cp docker-compose-ca.yaml docker-compose-ca-temp.yaml

#   # The next steps will replace the template's contents with the
#   # actual values of the private key file names for the two CAs.
#   CURRENT_DIR=$PWD
#   cd ../crypto-config/peerOrganizations/org1.example.com/ca/
#   PRIV_KEY=$(ls *_sk)
#   cd "$CURRENT_DIR"
#   sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" base/docker-compose-ca-temp.yaml

#   cd ../crypto-config/peerOrganizations/org2.example.com/ca/
#   PRIV_KEY=$(ls *_sk)
#   cd "$CURRENT_DIR"
#   sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" base/docker-compose-ca-temp.yaml
#   # If MacOSX, remove the temporary backup of the docker-compose file
#   if [ "$ARCH" == "Darwin" ]; then
#     rm docker-compose-ca-temp.yamlt
#   fi
#   echo "******************************keys set"
# }