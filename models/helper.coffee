# Rules
# (1) 예비용
# (2) 차량종류
# (3) 시간표
# (4) 배차간격
# (5) 요금
# (6) 공자사항:  법례 [서울 예약 전화는 055-1234-5678번입니다.]
# (7) 예비용
# (8) 예비용
# (9) 예비용
# (10) 예비용
# 위의 2~5가 루틴가능

module.exports.parseInformationBus = (source) ->
	result = {}
	result.source = source
	arrInfo = []
	info = {} # 차량 종류에 속하는 정보들 (2:차량종류, 3:시간표, 4:배차간격, 5:요금 및 소요시간)
	return if typeof source isnt 'string'
	arrFirst = source.split '('
	for i in [1..arrFirst.length] 		# 가장 첫번째 데이터는 시간과 무관함. 차량의 종류별 시간표들
		continue if typeof arrFirst[i] isnt 'string'
		currentNumber = 0
		parsedNumber = parseInt(arrFirst[i][0]) # '(' 으로 분할한 스트링중 첫번째 스트링은 숫자 이므로 그것으로 비교
		if !(parsedNumber > currentNumber ||			# 현 배열에 추가
		parsedNumber < 2 || parsedNumber > 5)			# 차량 종류 배열 외의 정보
			arrInfo.push info unless isEmptyObj(info)
			info = {}
		currentNumber = parsedNumber
		content = arrFirst[i].split('*')[0].substring(2)
		switch currentNumber
			when 1
				result.firstData = content
			when 6, 7, 8, 9, 10
			  result["reservedData"+(currentNumber-5)] = content
			when 2
				info.title = content
			when 3
				parsedContent = parseTimeTableFromString(content)
				info.timetable = parsedContent if parsedContent
			when 4
				info.interval = content
			when 5
				info.spendingTime = content
	arrInfo.push info unless isEmptyObj(info)
	if arrInfo.length > 0
		result.info = arrInfo
	return result

parseTimeTableFromString = (source) ->
	return null if typeof source isnt 'string'
	ampm = {}
	arrAmpmStr = source.replace('오전', '').split '오후'
	for str in arrAmpmStr						# 오전과 오후
		continue if typeof str isnt 'string'
		arrTime = []
		time = {}
		previousHour = 0
		str.replace /^\s+|\s+$/g, ""

		for timeStr in str.split(',')
			if typeof timeStr isnt 'string' or timeStr.length < 1 # 콤마(,) 전후의 빈 내용
				continue

			splitedTime = timeStr.split '시'

			if isNaN(hour = parseInt(splitedTime[0]))
				continue

			if isNaN(minute = parseInt(splitedTime[1]))
				minute = 0

			if previousHour is hour
			  time.minutes.push minute
			else
			  time = {hour: hour, minutes: [minute]}
			  arrTime.push time
			  
			previousHour = hour

		continue if arrTime.length == 0
		if arrAmpmStr.indexOf(str) == 0
			ampm.am = arrTime
		else #arrAmpmStr.indexOf(str) == 1
		  ampm.pm = arrTime
	ampm = null if isEmptyObj(ampm)
	return ampm

isEmptyObj = (obj) ->
	return false if obj.length and obj.length > 0
	return true if obj.length and obj.length == 0
	for key of obj
		return false if Object.prototype.hasOwnProperty.call(obj, key)
	return true