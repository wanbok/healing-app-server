Usage = require '../models/usage'
moment = require 'moment'

FORMAT = "YYYYMMDDHH"

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
				endTime: @endTime,
				duration: @duration,
				latitude: @latitude,
				longitude: @longitude,
				urlInfo: @urlInfo
			emit @appPkg, value

		o.reduce = (k, vals) ->
			reducedValue =
				userId: if vals && vals.length > 0 then vals[0].userId else null,
				appPkg: if vals && vals.length > 0 then vals[0].appPkg else null,
				durations: {},
				urlInfo: if vals && vals.length > 0 then vals[0].urlInfo else null

			for val in vals
				o.startTime = moment(o.startTime)
				o.endTime = moment(o.endTime)
				val.startTime = moment(val.startTime)
				val.endTime = moment(val.endTime)

				if o.startTime.isAfter(val.startTime)			# cut off before focus time
					val.duration -= moment(o.startTime).diff(moment(val.startTime))
					val.startTime = o.startTime

				if o.endTime.isBefore(var.endTime)				# cut off after focus time
					val.duration -= moment(o.endTime).diff(moment(val.endTime))
					val.endTime = o.endTime

				reducedValue.durations

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
				o.startTime = today.getMonth() - beginningAgo
				o.endTime = o.startTime + 1
				o.query.$or = [
					{startTime: {$gte: o.startTime, $lt: o.endTime}},
					{endTime: {$gte: o.startTime, $lt: o.endTime}}
				]
			when "weekly"
				o.startTime = today.getDate() - beginningAgo * 7
				o.endTime = o.startTime + 7
				o.query.$or = [
					{startTime: {$gte: o.startTime, $lt: o.endTime}},
					{endTime: {$gte: o.startTime, $lt: o.endTime}}
				]
			when "daily"
				o.startTime = today.getDate() - beginningAgo
				o.endTime = o.startTime + 1
				o.query.$or = [
					{startTime: {$gte: o.startTime, $lt: o.endTime}},
					{endTime: {$gte: o.startTime, $lt: o.endTime}}
				]
		console.log o.query.startTime
		@aggregateUsages o, callback

module.exports = new UsageService