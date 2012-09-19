Phone = require '../../models/phone'
phone = new Phone

routes = (app) ->
	app.namespace '/phones', ->
		app.get '/:udid', (req, res) -> # 해당 udid를 가지는 사용자의 가입여부를 알아냄
			phone.
		app.post '/', (req, res) -> # udid와 전화번호를 파라미터로 받아 저장함. 중복체크 필수



module.exports = routes