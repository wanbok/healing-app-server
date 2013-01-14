terminal = require '../../models/terminal'
SearchLog = require '../../models/searchlog'

routes = (app) ->
	app.namespace '/regions', ->
		app.get '/', (req, res) ->
			terminal.start_region (error, result) ->
				if error
					return resAsJson res, {error: "error"}
				return resAsJson res, result

	app.namespace '/terminals', ->
		app.get '/', (req, res) ->
			# 시작 지역은 일단 제거.
			# if req.query.start_region? # /terminals
			# 	# 해당 지역을 갖는 터미널 코드/터미널 명 리턴
			# 	if isEmptyQuery(res, "start_region", req.query.start_region)
			# 		return
			# 	return somthing
			if req.query.search?
				terminal.search req.query.search, (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					return resAsJson res, result
			else if req.query.start_region?
				terminal.start_terminal req.query.start_region, (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					return resAsJson res, result
			else
				terminal.all (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					return resAsJson res, result

		app.get '/samples', (req, res) ->
			terminal.sampleTimetable (error, result) ->	
				if error
					return resAsJson res, {error: "error"}
				return resAsJson res, result

		app.get '/search', (req, res) ->
			if req.query.latitude? and req.query.longitude?
				return resAsJson(res, [
					{name: "동서울터미널", tcode: 1, latitude: 37.540766, longitude: 127.09568},
					{name: "서울고속버스터미날(주)", tcode: 2, latitude: 37.512449, longitude: 127.006416},
					{name: "야탑역 고속버스터미널", tcode: 4, latitude: 37.417345, longitude: 127.130356}])
			res.json {error: "검색결과가 없습니다."}
	
		app.get '/:tcode', (req, res) ->
			if req.query.heng_code? # /terminals/:tcode?heng_code=도착터미널
				# 여기서 시간표 및 요금표 나옴
				if isEmptyQuery(res, "bang_code", req.query.bang_code)
					return
				if isEmptyQuery(res, "heng_code", req.query.heng_code)
					return
				terminal.timetable req.params.tcode, req.query.bang_code, req.query.heng_code, req.query.wcode, (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					if req.query.device_id?
						searchlog = {
							expression: result[0]['tname'] + " 출발, " + result[0]['heng_name'] + " 도착",
							tcode: result[0]['tcode'],
							bang_code: result[0]['bang_code'],
							heng_code: result[0]['heng_code'],
							device_id: req.query.device_id
							updated_date: Date.now()
						}
						SearchLog.update {expression: searchlog.expression}, {$set: searchlog}, {upsert: true}, (err, numberAffected, raw) ->
							if err
								console.log "SearchLog has an error"
							console.log "Number of SearchLog updated : #{numberAffected}"
					return resAsJson res, result

			else if req.query.bang_code? # /terminals/:tcode?bang_code=도착지역
				# 해당 터미널과 도착지역이 갖는 도착터미널 목록 리턴
				if isEmptyQuery(res, "bang_code", req.query.bang_code)
					return
				terminal.arrive_terminal req.params.tcode, req.query.bang_code, (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					return resAsJson res, result

			# /terminals/:tcode
			# 해당 터미널이 갖는 행선지(도착지역)목록 리턴
			else
				terminal.arrive_region req.params.tcode, (error, result) ->
					if error
						return resAsJson res, {error: "error"}
					return resAsJson res, result

resAsJson = (res, json) ->
	res.format
		json: ->
			res.json json

isEmptyQuery = (res, query, value) ->
	if typeof value is 'undefined' or value is null or value is ""
		res.json {error: "#{query} is empty"}
		return true


module.exports = routes