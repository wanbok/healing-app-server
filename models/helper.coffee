#동서울 직행 3000번 안내입니다. 포천, 내촌, 장현을 경유하며, 첫차는 오전 5시50분이고,막차는 오후 9시40분입니다.
#차량시각은 (@) 오전 5시50분, 6시40분, 7시20분, 8시, 8시40분, 9시10분, 9시40분, 10시10분, 10시50분, 11시30분,
#오후 12시10분, 12시50분, 1시30분, 2시10분, 2시50분, 3시30분, 4시10분, 4시50분, 5시20분, 6시, 6시40분, 7시20분,
#8시, 8시40분, 9시10분, 9시40분 (*)으로 소요시간은 약 1시간 40분입니다. 감사합니다.

module.exports.parseTimeTableFromString = (source) ->
	arrAmpm = []
	return if typeof source isnt 'string'
	arrFirst = source.split '(@)'
	for i in [1..arrFirst.length] 		# 가장 첫번째 데이터는 시간과 무관함. 차량의 종류별 시간표들
		continue if typeof arrFirst[i] isnt 'string'
		ampm = {}
		arrAmpmStr = arrFirst[i].split('(*)')[0].replace('오전', '').split '오후'
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

		arrAmpm.push {timetable: ampm} unless isEmptyObj(ampm)

	return arrAmpm

isEmptyObj = (obj) ->
	return false if obj.length and obj.length > 0
	return true if obj.length and obj.length == 0
	for key of obj
		return false if Object.prototype.hasOwnProperty.call(obj, key)
	return true