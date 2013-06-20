Usage = require '../models/usage'

class UsageService
	mapReduce: (o, callback) ->
		Usage.mapReduce o, (err, results) ->
			callback err, results

	aggregateUsages: (o, callback) ->
		o.map = () ->
			value =
				userId: @userId,
				appPkg: @appPkg,
				startTime: @startTime,
				duration: @duration,
				latitude: @latitude,
				longitude: @longitude,
				urlInfo: @urlInfo
			emit @appPkg, value

		o.reduce = (k, vals) ->
			reducedValue =
				userId: if vals && vals.length > 0 then vals[0].userId else null,
				appPkg: if vals && vals.length > 0 then vals[0].appPkg else null,
				duration: 0,
				urlInfo: if vals && vals.length > 0 then vals[0].urlInfo else null
			for val in vals
				reducedValue.duration += if val.duration isnt 'undefined' then val.duration else 0
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
				o.query.startTime = {$gte: today.setMonth(today.getMonth() - beginningAgo)}
			when "weekly" 
				o.query.startTime = {$gte: today.setDate(today.getDate() - beginningAgo * 7)}
			when "daily"
				o.query.startTime = {$gte: today.setDate(today.getDate() - beginningAgo)}
		console.log o.query.startTime
		@aggregateUsages o, callback

module.exports = new UsageService