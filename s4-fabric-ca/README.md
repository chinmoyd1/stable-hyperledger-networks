# Starting CA containers
docker-compose -f docker-compose-ca.yaml up

# Run gen-certs.sh to generate certs from CA
docker exec -it ca-client bash -c './scripts/gen-certs.sh'

# Copy client-config from ca-client to native sysatem
docker cp ca-client:/etc/hyperledger/fabric-ca-server/crypto-config ./crypto-config

# Generating genesis block
export FABRIC_CFG_PATH=$PWD
configtxgen -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block

# Cretae Channel Artifacts
configtxgen -profile MainChannel -outputCreateChannelTx ./channels/mainchannel.tx -channelID mainchannel
configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1-anchors.tx -channelID mainchannel -asOrg org1
configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2-anchors.tx -channelID mainchannel -asOrg org2

# Start Orderers and Peers
docker-compose up

# Create Channel
docker exec cli-peer0-org1 bash -c 'peer channel create -c mainchannel -f ./channels/mainchannel.tx -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem'

# Join Channel
docker exec cli-peer0-org1 bash -c 'peer channel join -b mainchannel.block'

# Fetch Channel's Genesis Block and Join Channel by other Peers
docker exec cli-peer1-org1 bash -c 'peer channel fetch 0 -o orderer0-service:7050 -c mainchannel --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem'
docker exec cli-peer1-org1 bash -c 'peer channel join -b mainchannel_0.block'

docker exec cli-peer0-org2 bash -c 'peer channel fetch 0 -o orderer0-service:7050 -c mainchannel --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem'
docker exec cli-peer0-org2 bash -c 'peer channel join -b mainchannel_0.block'

docker exec cli-peer1-org2 bash -c 'peer channel fetch 0 -o orderer0-service:7050 -c mainchannel --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem'
docker exec cli-peer1-org2 bash -c 'peer channel join -b mainchannel_0.block'

# Anchor Peers Update
docker exec cli-peer0-org1 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem -c mainchannel -f ./channels/org1-anchors.tx'

docker exec cli-peer0-org2 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem -c mainchannel -f ./channels/org2-anchors.tx'

# Install Chaincodes
docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'

# Instantiate Chaincode
docker exec -it cli-peer0-org1 bash 
peer chaincode instantiate -C mainchannel -n rawresources -v 0 -c '{"Args":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem

# Invoke Chaincode
docker exec -it cli-peer0-org1 bash 
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store","{\"id\":1, \"name\":\"Iron Ore\", \"weight\":42000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem

# Querry Chaincode
docker exec cli-peer0-org2 bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem"

# Updating Chaincode
docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 1'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 1'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 1'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 1'

docker exec cli-peer0-org1 bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 1 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem"


# Adding Records
docker exec -it cli-peer0-org1 bash

peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store","{\"id\":2, \"name\":\"Iron Ore\", \"weight\":42000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem

peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":2,\"name\":\"Magnasium Ore\",\"weight\":80000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem

# Checking Records 
peer chaincode query -C mainchannel -n rawresources -c '{"Args":["queryString", "{\"selector\":{ \"weight\": { \"$gt\":5000 } }}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem


##### Rough Entries ######
docker cp cli-peer0-org1:/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem .