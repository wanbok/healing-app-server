SearchLog = require '../../models/searchlog'

routes = (app) ->
	app.namespace '/searchlog', ->
		app.get '/:device_id', (req, res) -> # 해당 device_id를 가지는 사용자의 가입여부를 알아냄
			SearchLog.find({device_id: req.params.device_id}).sort({ updated_date: -1 }).exec (err, docs) ->
				if err?
					console.log err
					return res.json {error: "SearchLog has an error"}
				return res.json docs

module.exports = routes