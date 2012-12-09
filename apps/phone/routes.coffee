Phone = require '../../models/phone'

routes = (app) ->
	app.namespace '/phones', ->
		app.get '/:device_id', (req, res) -> # 해당 device_id를 가지는 사용자의 가입여부를 알아냄
			Phone.find {device_id: req.params.device_id}, (err, docs) ->
				# docs.forEach

		app.post '/', (req, res) -> # device_id와 전화번호를 파라미터로 받아 저장함. 중복체크 필수
			# for key, value of req.body
			#   console.log "key : #{key}, value : #{value}"
			if req.body.tel_number? and req.body.device_id?
				phone = new Phone { tel_number: req.body.tel_number, device_id: req.body.device_id }
				phone.save (err) ->
					if err
						console.log "Phone is not saved with this error : #{err}"
						res.json err
					else 
						res.json "success"

module.exports = routes