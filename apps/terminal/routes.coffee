
routes = (app) ->
	app.namespace '/terminals', ->
		app.get '/', (req, res) ->
			if req.query.start_region? # /terminals
				# 해당 지역을 갖는 터미널 코드/터미널 명 리턴
				if isEmptyQuery(res, "start_region", req.query.start_region)
					return
				return resAsJson(res, [{name: "동서울터미널", tcode: 1}, {name: "서울 남부터미널", tcode: 2}, {name: "상봉터미널", tcode: 3}, {name: "서부시외버스터미널", tcode: 4}])
			
			return resAsJson(res, [{name: "서울", code: 1}, {name: "부산", code: 2}])

		app.get '/search', (req, res) ->
			if req.query.latitude? and req.query.longitude?
				return resAsJson(res, [
					{name: "동서울터미널", tcode: 1, latitude: 37.540766, longitude: 127.09568},
				 	{name: "서울고속버스터미날(주)", tcode: 2, latitude: 37.512449, longitude: 127.006416},
				 	{name: "야탑역 고속버스터미널", tcode: 4, latitude: 37.417345, longitude: 127.130356}])
			
			res.json {error: "검색결과가 없습니다."}
			
		app.get '/:tcode', (req, res) ->
			if req.query.arrive_region? # /terminals/:tcode?arrive_region=도착지역
				# 해당 터미널과 도착지역이 갖는 도착터미널 목록 리턴
				if isEmptyQuery(res, "arrive_region", req.query.arrive_region)
					return
				return resAsJson(res, [{name: "전북터미널", code: 1}, {name: "광주터미널", code: 2}, {name: "전남터미널", code: 3}])

			if req.query.arrive_terminal? # /terminals/:tcode?arrive_terminal=도착터미널
				# 여기서 시간표 및 요금표 나옴
				if isEmptyQuery(res, "arrive_terminal", req.query.arrive_terminal)
					return
				data = [
					{name: "전북터미널", code: 1, timetables: [{time: "11:10"}, {time: "15:10"}, {time: "19:00"}], charge: 10000},
				 	{name: "광주터미널", code: 2, timetables: [{time: "10:00"}, {time: "16:00"}, {time: "22:00"}], charge: 12000},
				 	{name: "전남터미널", code: 3, timetables: [{time: "16:00"}, {time: "19:45"}, {time: "24:00"}], charge: 15000}
				]
				return resAsJson(res, data)

			# /terminals/:tcode
			# 해당 터미널이 갖는 행선지(도착지역)목록 리턴
			return resAsJson(res, [{name: "전라도", code: 1}, {name: "경상도", code: 2}, {name: "충청도", code: 3}])




resAsJson = (res, json) ->
	res.format
		json: ->
			res.json json

isEmptyQuery = (res, query, value) ->
	if value is "" or null
		res.json {error: "#{query} is empty"}
		return true


module.exports = routes