
routes = (app) ->
	app.namespace '/notifier', ->
		app.get '/', (req, res) ->	# ARS 서버에서 결제되었음을 보냄
			# if _.isEqual(req.ip, '127.0.0.1') # ARS 서버 ip확인
				console.log "Accepted to notify for #{req.query.tel} by ARS Server(#{req.ip})"
				for key, value of req.query
				  console.log "key : #{key}, value : #{value}"
				console.log 
				res.send 202, { message: 'Complete to notify', code: 100 }
			# else
			# 	res.send 403, { message: 'Wrong access' }

module.exports = routes