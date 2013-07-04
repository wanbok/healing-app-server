GCM = require('gcm').GCM;
apiKey = 'AIzaSyBYKzt9H_fsKohlZiCWn7BAWglmpz3vf0g'
gcm = new GCM(apiKey)

class GCMController
	test: (req, res) ->
		if typeof req.query.registration_id isnt 'undefined'
			message =
				registration_id: req.query.registration_id,
				collapse_key: 'test key',
				time_to_live: 3,
				delay_while_idle: true,
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

	forbidden: (registration_id, appPkg) ->
		message =
			registration_id: registration_id,
			collapse_key: 'forbidden',
			time_to_live: 3,
			delay_while_idle: true,
			msg: '금지시간이 업데이트 되었습니다.',
			'data.flag': 'forbidden',
			'data.package': appPkg
			
		gcm.send message, gcmCallback

	survey: (survey_id, registration_id) ->
		message =
			registration_id: registration_id,
			collapse_key: 'survey',
			time_to_live: 3,
			delay_while_idle: true,
			msg: '설문에 참여해주세요.',
			'data.flag': 'survey'
			'data.survey_id' : survey_id
		gcm.send message, gcmCallback

	notice: (notice, registration_id) ->
		message =
			registration_id: registration_id,
			collapse_key: 'notice',
			time_to_live: 3,
			delay_while_idle: true,
			msg: '공지사항',
			'data.flag': 'notice'
			'data.notice' : notice
		gcm.send message, gcmCallback

module.exports = new GCMController

gcmCallback = (err, messageId) ->
	if err?
		console.log ("GCM Error : " + err)
	else
		console.log ("Succeed to send GCM messageId : " + messageId)