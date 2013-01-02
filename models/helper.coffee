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
	isOrderedNumber = source.indexOf('(@)') < 0
	source = source.replace(/\(\?\)/g, " ") if source.indexOf('(?)') > -1
	source = source.replace(/\(\?\?\)/g, "\r\n") if source.indexOf('(??)') > -1
	console.log source
	result = {}
	result.source = source
	arrInfo = []
	info = {} # 차량 종류에 속하는 정보들 (2:차량종류, 3:시간표, 4:배차간격, 5:요금 및 소요시간)
	currentNumber = 0
	return if typeof source isnt 'string'
	arrFirst = source.split '('
	for i in [1..arrFirst.length] 		# 가장 첫번째 데이터는 시간과 무관함. 차량의 종류별 시간표들
		continue if typeof arrFirst[i] isnt 'string'
		parsedString = arrFirst[i][0..1]
		parsedNumber = parseInt(parsedString) # '(' 으로 분할한 스트링중 첫번째 스트링은 숫자 이므로 그것으로 비교
		if (isOrderedNumber and !(parsedNumber > currentNumber)) or
		(!isOrderedNumber and parsedString[0] is '@')
			# 현 배열에 추가
			arrInfo.push info unless isEmptyObj(info)
			info = {}
			continue if isNaN(parsedNumber)

		currentNumber = parsedNumber
		contentBeforeParse = arrFirst[i].split('*')[0]
		content = contentBeforeParse.substring(contentBeforeParse.indexOf(')')+1).replace /^\s+|\s+$/g, ""
		switch currentNumber
			when 1
				info.firstData = content
			when 8,9,10,11,12,13,14,15
			  info["reservedData"+(currentNumber-7)] = content
			when 2
				info.title = content
			when 3
				parsedContent = parseTimeTableFromString(content)
				info.timetable = parsedContent if parsedContent
			when 4
				info.interval = content
			when 5
				info.spendingTime = content
			when 6
				info.charge = content
			when 7
				info.passage = content
	arrInfo.push info unless isEmptyObj(info)
	if arrInfo.length > 0
		result.info = arrInfo
	return result

parseTimeTableFromString = (source) ->
	return null if typeof source isnt 'string'
	source = convertCommaToAnotherComma source		# 시간표 분 옆의 대괄호 속 콤마들을 파싱오류를 일으키게 하지 않게 바꿔둔다.
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

			extractedMessageIndex = timeStr.indexOf('[')
			hasExtractedMessage = extractedMessageIndex > -1
			extractedMessage = String.new
			if hasExtractedMessage
			  extractedMessage = revertCommaFromAnotherComma(timeStr.substring(extractedMessageIndex + 1, timeStr.indexOf(']')))
			  timeStr = timeStr.split('[')[0]
			
			splitedTime = timeStr.split '시'

			if isNaN(hour = parseInt(splitedTime[0]))
				continue

			minute = {}
			if isNaN(minute.minute = parseInt(splitedTime[1]))
				minute.minute = 0

			if hasExtractedMessage
				minute.message = extractedMessage

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

convertCommaToAnotherComma = (source) ->
	endIndex = 0
	while (startIndex = source.indexOf('[', endIndex + 1)) > -1
		if (endIndex = source.indexOf(']', startIndex + 1)) > -1
			betweenStr = source[startIndex...endIndex].replace(/,/gi, '、')
			source = source.substring(0, startIndex) + betweenStr + source.substring(endIndex)
			# console.log startIndex + " " + endIndex + " " + betweenStr + " " + source
		else
			break
	return source

revertCommaFromAnotherComma = (source) ->
	return source.replace(/、/g, ',')


isEmptyObj = (obj) ->
	return false if obj.length and obj.length > 0
	return true if obj.length and obj.length == 0
	for key of obj
		return false if Object.prototype.hasOwnProperty.call(obj, key)
	return true