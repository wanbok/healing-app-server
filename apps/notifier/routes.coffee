Phone = require '../../models/phone'
gcm = require 'node-gcm'
apns = require 'apn'
options = {
	cert: 'cert.pem',                 # Certificate file path
	certData: null,                   # String or Buffer containing certificate data, if supplied uses this instead of cert file path
	key:  'key.pem',                  # Key file path
	keyData: null,                    # String or Buffer containing key data, as certData
	passphrase: null,                 # A passphrase for the Key file
	ca: null,                         # String or Buffer of CA data to use for the TLS connection
	pfx: null,                        # File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above
	pfxData: null,                    # PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk.
	gateway: 'gateway.push.apple.com',# gateway address
	port: 2195,                       # gateway port
	rejectUnauthorized: true,         # Value of rejectUnauthorized property to be passed through to tls.connect()
	enhanced: true,                   # enable enhanced format
	errorCallback: undefined,         # Callback when error occurs function(err,notification)
	cacheLength: 100                  # Number of notifications to cache for error purposes
	autoAdjustCache: true,            # Whether the cache should grow in response to messages being lost after errors.
	connectionTimeout: 0              # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled.
}


routes = (app) ->
	app.namespace '/notifier', ->
		app.get '/', (req, res) ->	# ARS 서버에서 결제되었음을 보냄
			# if _.isEqual(req.ip, '127.0.0.1') # ARS 서버 ip확인
				console.log "Accepted to notify for #{req.query.tel} by ARS Server(#{req.ip})"
				for key, value of req.query
					console.log "key : #{key}, value : #{value}"
				Phone.find {tel_number: req.query.tel}, (err, docs) ->
					if err?
						res.send 202, { message: 'Unregistered device_id', code: 200 }
						return
					target = []
					for doc in docs
						target.push doc.device_id
					console.log target
					sendToPushNotificationServer req.query, target
					res.send 202, { message: 'Complete to notify', code: 100 }
			# else
			# 	res.send 403, { message: 'Wrong access' }

sendToPushNotificationServer = (data, target) ->
	# target must be an array
	message = new gcm.Message()
	sender = new gcm.Sender 'AIzaSyAGBMcIidpjxL6CIklIdUp6dWqCipGzMu4'
	message.collapseKey = 'test'
	message.delayWhileIdle = true
	message.timeToLive = 3
	message.addData 'msg', 'test'
	message.addData 'tcode', data.tcode
	message.addData 'bang_code', data.bang_code
	message.addData 'heng_code', data.heng_code
	message.addData 'wcode', data.wcode

	sender.send message, target, 4, (err, result) ->
		console.log result

module.exports = routes