'use strict';

const FabricCAServices = require('fabric-ca-client');
const { FileSystemWallet,  X509WalletMixin } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const ccpPath = path.resolve(__dirname,'profiles' ,'dev-connection.yaml');
const ccpYAML = fs.readFileSync(ccpPath, 'utf8');
const ccp = yaml.safeLoad(ccpYAML);
const mspID = 'org1';

async function main() {
    try {

        // Create a new CA client for interacting with the CA.
        const caInfo = ccp.certificateAuthorities['ca-intermediate'];
        const caTLSCACerts = caInfo.tlsCACerts.pem;
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);

        // Create a new file system based wallet for managing identities.
        const walletPath = './wallet';
        const wallet = new FileSystemWallet(walletPath);
        //const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identityName = createIdentityLabel('org1','Admin');
        const identity = await wallet.export(identityName);
        if (identity) {
            console.log(`An identity for the admin user "${identityName}" already exists in the wallet`);
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        console.log('enrolled...')
  
        const identityLabel = createIdentityLabel('org1','Admin');

        const identity1 = X509WalletMixin.createIdentity(mspID, enrollment.certificate, enrollment.key.toBytes());
        await wallet.import(identityLabel, identity1);

        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
        process.exit(1);
    }
}

function createIdentityLabel(org, user){
    return user+'@'+org+'.default.svc.cluster.local';
}

main();