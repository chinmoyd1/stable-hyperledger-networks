/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, FileSystemWallet, X509WalletMixin } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const yaml = require('js-yaml');

const ADMIN_ID = 'Admin@org1.default.svc.cluster.local'
const USER_ID = 'User3@org1.default.svc.cluster.local'
const ccpPath = path.resolve(__dirname,'profiles' ,'dev-connection.yaml');
const ccpYAML = fs.readFileSync(ccpPath, 'utf8');
const connectionProfile = yaml.safeLoad(ccpYAML);

async function main() {
    try {

        // Create a new file system based wallet for managing identities.
        //const walletPath = path.join(process.cwd(), 'wallet');
        const walletPath = './wallet';

        const wallet = new FileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        //const userIdentity = await wallet.get('user1');
        const userIdentity = await wallet.export(USER_ID);
        if (userIdentity) {
            console.log('An identity for the user "user3" already exists in the wallet');
            return;
        }

        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.export(ADMIN_ID);
        if (!adminIdentity) {
            console.log(`An identity for the admin user "${ADMIN_ID}" does not exist in the wallet`);
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(connectionProfile, { wallet, identity: ADMIN_ID, discovery: { enabled: true, asLocalhost: true } });

        console.log('Connection..Successfull..');
        // Get the CA client object from the gateway for interacting with the CA.
        const client = gateway.getClient();
        console.log('client retrived...')
        const ca = client.getCertificateAuthority();
        console.log('CA retrived...')

        const adminUser = await client.getUserContext(ADMIN_ID, false);
        console.log('User context retrived...')

        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({ affiliation: 'org1', enrollmentID: USER_ID, role: 'client' }, adminUser);
        console.log('registered...')

        const enrollment = await ca.enroll({ enrollmentID: USER_ID, enrollmentSecret: secret });
        console.log('enrolled...')

        const x509Identity = X509WalletMixin.createIdentity('org1', enrollment.certificate, enrollment.key.toBytes());
        await wallet.import(USER_ID, x509Identity);
        console.log('Successfully registered and enrolled admin user "user1" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to register user "user1": ${error}`);
        process.exit(1);
    }
}

main();