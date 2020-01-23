chmod +x *.sh
chmod +x -R scripts

echo
echo "*****************************************************************"
echo "*****************************************************************"
echo "#######           Strating the CA Network              ##########"
echo "*****************************************************************"
echo "*****************************************************************"
export IMAGE_TAG=latest
docker-compose -f docker-compose-ca.yaml up -d 2>&1
sleep 1
docker ps -a
if [ $? -ne 0 ]; then
  echo "ERROR !!!! Unable to start CA network"
  exit 1
fi

sleep 2

echo
echo "*****************************************************************"
echo "*****************************************************************"
echo "###   Generating Certs for creating crypto material from CA   ###"
echo "*****************************************************************"
echo "*****************************************************************"
echo
docker exec ca-client scripts/gen-certs.sh
if [ $? -ne 0 ]; then
    echo "ERROR !!!! Cert Creation Failed"
    exit 1
fi

rm -rf crypto-config
docker cp ca-client:/etc/hyperledger/fabric-ca-server/crypto-config .
sleep 2

echo
echo "*****************************************************************"
echo "*****************************************************************"
echo "#######          Generating Channnel Artifacts         ##########"
echo "*****************************************************************"
echo "*****************************************************************"
./setup.sh
if [ $? -ne 0 ]; then
  echo "ERROR !!!! Unable to Generate Channel Artifacts"
  exit 1
fi