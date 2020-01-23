var fs = require('fs');
var path = require('path');

var helper = require('./helper.js');
var logger = helper.getLogger('Create-Channel');
//Attempt to send a request to the orderer with the sendTransaction method
var createChannel = async function(channelName, channelConfigPath, username, orgName) {
	logger.debug('\n====== Creating Channel \'' + channelName + '\' ======\n');
	try {
		// first setup the client for this org
		var client = await helper.getClientForOrg(orgName,'Admin');
		logger.debug('Successfully got the fabric client for the organization "%s"', orgName);

		// read in the envelope for the channel config raw bytes
		var fullyQualofoedChannelConfigPath = path.join(__dirname, channelConfigPath);
		console.log('channelTx location: ', fullyQualofoedChannelConfigPath);
		var envelope = fs.readFileSync(fullyQualofoedChannelConfigPath);
		// extract the channel config bytes from the envelope to be signed
		console.log(envelope);
		var channelConfig = client.extractChannelConfig(envelope);

		//Acting as a client in the given organization provided with "orgName" param
		// sign the channel config bytes as "endorsement", this is required by
		// the orderer's channel creation policy
		// this will use the admin identity assigned to the client when the connection profile was loaded
		let signature = client.signChannelConfig(channelConfig);

		let request = {
			config: channelConfig,
			signatures: [signature],
			name: channelName,
			txId: client.newTransactionID(true) // get an admin based transactionID
		};

		// send to orderer
		const result = await client.createChannel(request)
		logger.debug(' result ::%j', result);
		if (result) {
			if (result.status === 'SUCCESS') {
				logger.debug('Successfully created the channel.');
				const response = {
					success: true,
					message: 'Channel \'' + channelName + '\' created Successfully'
				};
				return response;
			} else {
				logger.error('Failed to create the channel. status:' + result.status + ' reason:' + result.info);
				const response = {
					success: false,
					message: 'Channel \'' + channelName + '\' failed to create status:' + result.status + ' reason:' + result.info
				};
				return response;
			}
		} else {
			logger.error('\n!!!!!!!!! Failed to create the channel \'' + channelName +
				'\' !!!!!!!!!\n\n');
			const response = {
				success: false,
				message: 'Failed to create the channel \'' + channelName + '\'',
			};
			return response;
		}
	} catch (err) {
		logger.error('Failed to initialize the channel: ' + err.stack ? err.stack :	err);
		throw new Error('Failed to initialize the channel: ' + err.toString());
	}
};

createChannel('mainchannel', '../channels/mainchannel.tx', 'Admin@org1.default.svc.cluster.local', 'org1');

exports.createChannel = createChannel;