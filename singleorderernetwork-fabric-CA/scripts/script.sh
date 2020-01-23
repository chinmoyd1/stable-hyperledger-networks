#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Single Node Network end-to-end test"
echo
DELAY="3"

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

echo "Creating channel..."
peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx
verifyResult $res "Channel creation failed"
echo "===================== Channel 'mychannel' created ===================== "
echo


echo "Having all peers join the channel..."
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    set -x
        peer channel join -b mychannel.block
        res=$?
    set +x
verifyResult $res "Channel creation failed"
echo "===================== peer0.org1 joined channel 'mychannel' ===================== "
sleep $DELAY
echo
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer1.org1.example.com:8051
    set -x
        peer channel join -b mychannel.block
        res=$?
    set +x
verifyResult $res "Channel creation failed"
echo "===================== peer1.org1 joined channel 'mychannel' ===================== "
sleep $DELAY
echo
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
    set -x
        peer channel join -b mychannel.block
        res=$?
    set +x
verifyResult $res "Channel creation failed"
echo "===================== peer0.org2 joined channel 'mychannel' ===================== "
sleep $DELAY
echo
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer1.org2.example.com:10051
    set -x
        peer channel join -b mychannel.block
        res=$?
    set +x
verifyResult $res "Channel creation failed"
echo "===================== peer1.org2 joined channel 'mychannel' ===================== "
sleep $DELAY
echo

echo "Updating anchor peers for org1..."
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
set -x
    peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx
    res=$?
set +x
verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org1 on channel mychannel ===================== "
sleep $DELAY
echo

echo "Updating anchor peers for org2..."
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
set -x
    peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx
    res=$?
set +x
verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org2 on channel mychannel ===================== "
sleep $DELAY
echo

echo "Installing chaincode on peer0.org1..."
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
set -x
    peer chaincode install -l golang -p rawresources -n rawresources -v 0
    res=$?
set +x
verifyResult $res "Chaincode installation on peer0.org1 has failed"
echo "===================== Chaincode is installed on peer0.org1 ===================== "
sleep $DELAY
echo

echo "Installing chaincode on peer0.org2..."
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
set -x
    peer chaincode install -l golang -p rawresources -n rawresources -v 0
    res=$?
set +x
verifyResult $res "Chaincode installation on peer0.org2 has failed"
echo "===================== Chaincode is installed on peer0.org2 ===================== "
sleep $DELAY
echo



echo "Instantiating chaincode on peer0.org2..."
set -x
    peer chaincode instantiate -C mychannel -n rawresources -v 0 -c '{"Args":[]}' -o orderer.example.com:7050
    res=$?
set +x
verifyResult $res "Chaincode instantiation on peer0.org2 on channel 'mychannel' failed"
echo "===================== Chaincode is instantiated on peer0.org2 on channel 'mychannel' ===================== "
sleep $DELAY
echo


echo "Sending invoke transaction on peer0.org2..."
set -x
    peer chaincode invoke -C mychannel -n rawresources -c '{"Args":["index","0","1000000"]}' -o orderer.example.com:7050
    res=$?
set +x
verifyResult $res  "Invoke execution on peer0.org2 failed"
echo "===================== Invoke transaction successful on peer0.org2 on channel 'mychannel' ===================== "
sleep $DELAY
echo
set -x
    peer chaincode invoke -C mychannel -n rawresources -c '{"Args":["store","{\"id\":1, \"name\":\"Iron Ore\", \"weight\":42000}"]}' -o orderer.example.com:7050
    res=$?
set +x
verifyResult $res  "Invoke execution on peer0.org2 failed"
echo "===================== Invoke transaction successful on peer0.org2 on channel 'mychannel' ===================== "
sleep $DELAY
echo


echo
echo "========= All GOOD, Test execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0