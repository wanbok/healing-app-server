
routes = (app) ->
	app.namespace '/payments', ->
		app.post '/', (req, res) ->	# ARS 서버에서 결제되었음을 보냄
			if _.isEqual(req.ip, '127.0.0.1') # ARS 서버 ip확인
				console.log "Accepted to payment 1day-ticket for #{req.query.tel} by ARS Server(#{req.ip})"
				res.send 202, { message: 'Complete to payment' }
			else
				res.send 403, { message: 'Wrong access' }

		# 결제 여부를 체크함
		# return:
		#   code: 1, message: 결제됨
		#   code: 9, message: 결제되지 않음
		#   code: 99, message: 가입되지 않음
		app.get '/:udid', (req, res) ->
			res.json {error: ""}

module.exports = routes