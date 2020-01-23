/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, FileSystemWallet, Wallets } = require('fabric-network');
const path = require('path');

const ccpPath = path.resolve(__dirname,'profiles' ,'dev-connection.yaml');
const ADMIN_ID = 'Admin@org1.default.svc.cluster.local'

async function main() {
    try {

        // Create a new file system based wallet for managing identities.
        const walletPath = './wallet';
        const wallet = new FileSystemWallet(walletPath);
        //console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.export(ADMIN_ID);
        if (!identity) {
            console.log('An identity for the user "user1" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccpPath, { wallet, identity: ADMIN_ID, discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('mainchannel');

        // Get the contract from the network.
        const contract = network.getContract('rawresources');

        // Submit the specified transaction.
        // createCar transaction - requires 5 argument, ex: ('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom')
        // changeCarOwner transaction - requires 2 args , ex: ('changeCarOwner', 'CAR10', 'Dave')
        await contract.submitTransaction('store', '{"id":2,"name":"Copper Ore","weight":80000}');
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

main();