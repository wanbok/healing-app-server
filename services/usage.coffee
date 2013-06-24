Usage = require '../models/usage'

FORMAT = "YYYYMMDDHH"

class UsageService
	mapReduce: (o, callback) ->
		Usage.mapReduce o, (err, results) ->
			if err?
				console.log err
			callback err, results

	aggregateUsages: (o, callback) ->
		o.map = () ->
			value =
				userId: @userId,
				appPkg: @appPkg,
				startTime: @startTime,
				endTime: @endTime,
				duration: @duration,
				latitude: @latitude,
				longitude: @longitude,
				urlInfo: @urlInfo

			if startTime? and startTime > value.startTime		# cut off before focus time
				value.raw =
					duration: value.duration
					startTime: value.startTime
				value.duration -= abs(startTime - value.startTime)
				value.startTime = startTime

			if endTime? and endTime < value.endTime					# cut off after focus time
				value.raw =
					duration: value.duration
					endTime: value.endTime
				value.duration -= abs(endTime - value.endTime)
				value.endTime = endTime

			emit @appPkg, value

		o.reduce = (k, vals) ->
			reducedValue =
				userId: if vals && vals.length > 0 then vals[0].userId else null,
				appPkg: if vals && vals.length > 0 then vals[0].appPkg else null,
				totalDuration: 0,
				durations: {},
				urlInfo: if vals && vals.length > 0 then vals[0].urlInfo else null

			for val in vals
				#startTime is date as number
				#endTime is date as number
				val.startTime = val.startTime.getTime()
				val.endTime = val.endTime.getTime()

				while val.duration > 0
					previousStartTime = val.startTime
					next = new Date(val.startTime + 60 * 60 * 1000)
					val.startTime = new Date(next.getFullYear(), next.getMonth(), next.getDate(), next.getHours(), 0, 0, 0).getTime()
					duration = Math.min(val.duration, val.startTime - previousStartTime)
					previousStartTime = new Date(previousStartTime)
					keyDate = new Date(previousStartTime.getFullYear(), previousStartTime.getMonth(), previousStartTime.getDate(), previousStartTime.getHours(), 0, 0, 0)
					key = new String(keyDate.getFullYear())
					key += if (keyDate.getMonth() + 1) < 10 then "0" else ""	# 한자리수 월단위를 0x로. (e.g. 2월 => 02)
					key += keyDate.getMonth() + 1
					key += if keyDate.getDate() < 10 then "0" else ""					# 한자리수 일단위를 0x로. (e.g. 5일 => 05)
					key += keyDate.getDate()
					reducedValue.durations[key] = reducedValue.durations[key] || 0
					reducedValue.durations[key] += duration
					reducedValue.totalDuration += duration
					val.duration -= duration

			return reducedValue

		@mapReduce o, callback

	usagesByParams: (query, callback) ->
		o = {}
		o.query = {userId: query.userId}
		if typeof query.appPkg isnt 'undefined' then o.query.appPkg = query.appPkg
		beginningAgo = if query.beginningAgo then query.beginningAgo else 1
		# new Date(year, month, day, hours, minutes, seconds, milliseconds);
		today = new Date()
		baseDate = new Date(today.getFullYear(), today.getMonth(), 1, 0, 0, 0, 0)
		switch query.scope
			when "monthly"
				startTime = today.getMonth() - beginningAgo
				endTime = startTime + 1
				o.query.$or = [
					{startTime: {$gte: startTime, $lt: endTime}},
					{endTime: {$gte: startTime, $lt: endTime}}
				]
			when "weekly"
				startTime = today.getDate() - beginningAgo * 7
				endTime = startTime + 7
				o.query.$or = [
					{startTime: {$gte: startTime, $lt: endTime}},
					{endTime: {$gte: startTime, $lt: endTime}}
				]
			when "daily"
				startTime = today.getDate() - beginningAgo
				endTime = startTime + 1
				o.query.$or = [
					{startTime: {$gte: startTime, $lt: endTime}},
					{endTime: {$gte: startTime, $lt: endTime}}
				]

		o.scope = {}
		if startTime?
			o.scope.startTime = startTime
		if endTime?
			o.scope.endTime = endTime

		@aggregateUsages o, callback

module.exports = new UsageService