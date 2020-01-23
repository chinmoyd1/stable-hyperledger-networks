/**
 * Demonstrates the use of Gateway Network & Contract classes
 */
 const path = require('path');
 // Needed for reading the connection profile as JS object
 const fs = require('fs');
 // Used for parsing the connection profile YAML file
 const yaml = require('js-yaml');
 // Import gateway class
 const { Gateway, FileSystemWallet, DefaultEventHandlerStrategies, Transaction  } = require('fabric-network');
 
 // Constants for profile
 const CONNECTION_PROFILE_PATH =  path.resolve(__dirname,'profiles' ,'dev-connection.yaml');
 // Path to the wallet
 const FILESYSTEM_WALLET_PATH = path.resolve(__dirname,'wallet');
 // Identity context used
 const USER_ID = 'Admin@org1.default.svc.cluster.local'
 // Channel name
 const NETWORK_NAME = 'mainchannel'
 // Chaincode
 const CONTRACT_ID = 'rawresources'
 
 
 
 // 1. Create an instance of the gatway
 const gateway = new Gateway();
 
 // Sets up the gateway | executes the invoke & query
 main()
 
 /**
  * Executes the functions for query & invoke
  */
 async function main() {

     await setupGateway()

     let network = await gateway.getNetwork(NETWORK_NAME)

     const contract = await network.getContract(CONTRACT_ID);
 

     //7. Query the chaincode
     await queryContract(contract)
 

 
 }
 
 /**
  * Queries the chaincode
  * @param {object} contract 
  */
 async function queryContract(contract){
     try{
         // Query the chaincode
         let response = await contract.evaluateTransaction('queryString', '{"selector":{ "weight": { "$gt":5000 } }}')
         console.log(`Query Response=${response.toString()}`)
     } catch(e){
         console.log(e)
     }
 }
 

 
 /**
  * Function for setting up the gateway
  * It does not actually connect to any peer/orderer
  */
 async function setupGateway() {
     
     // 2.1 load the connection profile into a JS object
     let connectionProfile = yaml.safeLoad(fs.readFileSync(CONNECTION_PROFILE_PATH, 'utf8'));
 
     // 2.2 Need to setup the user credentials from wallet
     const wallet = new FileSystemWallet(FILESYSTEM_WALLET_PATH)
 
     // 2.3 Set up the connection options
     let connectionOptions = {
         identity: USER_ID,
         wallet: wallet,
         discovery: { enabled: false, asLocalhost: true }
         /*** Uncomment lines below to disable commit listener on submit ****/
         // , eventHandlerOptions: {
         //     strategy: null
         // } 
     }
 
     // 2.4 Connect gateway to the network
     await gateway.connect(connectionProfile, connectionOptions)
 }
