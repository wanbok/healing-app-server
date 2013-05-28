GCM = require('gcm').GCM;
apiKey = 'AIzaSyBYKzt9H_fsKohlZiCWn7BAWglmpz3vf0g'
gcm = new GCM(apiKey)

class GCMController
	test: (req, res) ->
		if typeof req.query.registration_id isnt 'undefined'
			message =
				registrationId: req.query.registration_id,
				collapseKey: 'Collapsekey',
				msg: 'Success to test GCM!',
				'data.key1': 'value1',
				'data.key2': 'value2'
			gcm.send message, (err, messageId) ->
				if err
					res.json {error_meesage: err}
				else
					res.json {message_id: "Sent with message ID: " + messageId, message: message}
		else
			res.render 'index',
				title: 'Welcome! You can test GCM by your Android.'

module.exports = new GCMController