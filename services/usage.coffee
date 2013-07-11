Usage = require '../models/usage'

FORMAT = "YYYYMMDDHH"

class UsageService
  mapReduce: (o, callback) ->
    Usage.mapReduce o, (err, docs) ->
      if err?
        console.log err
      callback err, docs

  aggregateUsagesByParams: (o, callback) ->
    o.map = () ->
      # raw =
      #   duration: @duration,
      #   startTime: @startTime,
      #   endTime: @endTime

      value =
        userId: @userId,
        appPkg: @appPkg,
        startTime: @startTime,
        endTime: @endTime,
        duration: @duration,
        durations: {},
        # latitude: @latitude,
        # longitude: @longitude,
        urlInfo: @urlInfo #,
        # raw: raw

      if startTime? and startTime > value.startTime   # cut off before focus time
        # value.raw =
        #   duration: value.duration
        #   startTime: value.startTime
        value.duration -= Math.abs(startTime - value.startTime)
        value.startTime = startTime

      if endTime? and endTime < value.endTime         # cut off after focus time
        # value.raw =
        #   duration: value.duration
        #   endTime: value.endTime
        value.duration -= Math.abs(endTime - value.endTime)
        value.endTime = endTime

      emit @appPkg, value

    o.reduce = (k, vals) ->
      # raw =
      #   duration: @duration,
      #   startTime: @startTime,
      #   endTime: @endTime

      reducedValue =
        userId: vals[0].userId,
        appPkg: vals[0].appPkg,
        startTime: vals[0].startTime,
        endTime: vals[vals.length - 1].endTime,
        duration: 0,
        durations: {},
        # latitude: 0,
        # longitude: 0,
        urlInfo: vals[0].urlInfo #,
        # raw: raw

      for val in vals
        #startTime is date as number
        #endTime is date as number
        val.startTime = if val.startTime instanceof Date then val.startTime.getTime() else val.startTime
        val.endTime = if val.endTime instanceof Date then val.endTime.getTime() else val.endTime

        while val.duration > 0
          previousStartTime = val.startTime
          next = new Date(val.startTime + 60 * 60 * 1000)
          val.startTime = new Date(next.getFullYear(), next.getMonth(), next.getDate(), next.getHours(), 0, 0, 0).getTime()
          duration = Math.min(val.duration, val.startTime - previousStartTime)
          previousStartTime = new Date(previousStartTime)
          keyDate = new Date(previousStartTime.getFullYear(), previousStartTime.getMonth(), previousStartTime.getDate(), previousStartTime.getHours(), 0, 0, 0)
          key = new String(keyDate.getFullYear())
          key += if (keyDate.getMonth() + 1) < 10 then "0" else ""  # 한자리수 월단위를 0x로. (e.g. 2월 => 02)
          key += keyDate.getMonth() + 1
          key += if keyDate.getDate() < 10 then "0" else ""         # 한자리수 일단위를 0x로. (e.g. 5일 => 05)
          key += keyDate.getDate()
          reducedValue.durations[key] = reducedValue.durations[key] || 0
          reducedValue.durations[key] += duration
          reducedValue.duration += duration
          val.duration -= duration

      return reducedValue

    @mapReduce o, callback

  usagesByParams: (query, callback) ->
    o = {}
    o.query = {userId: query.userId}
    if typeof query.appPkg isnt 'undefined' then o.query.appPkg = query.appPkg
    beginningAgo = if query.beginningAgo then query.beginningAgo else 1
    # new Date(year, month, day, hours, minutes, seconds, milliseconds);
    switch query.scope
      when "monthly"
        startTime = moment().startOf('month').subtract('months', beginningAgo).valueOf()
        endTime = moment().endOf('month').subtract('months', beginningAgo).valueOf()
        o.query.$or = [
          {startTime: {$gte: startTime, $lte: endTime}},
          {endTime: {$gte: startTime, $lte: endTime}}
        ]
      when "weekly"
        startTime = moment().startOf('week').subtract('weeks', beginningAgo).valueOf()
        endTime = moment().endOf('week').subtract('weeks', beginningAgo).valueOf()
        o.query.$or = [
          {startTime: {$gte: startTime, $lte: endTime}},
          {endTime: {$gte: startTime, $lte: endTime}}
        ]
      when "daily"
        startTime = moment().startOf('day').subtract('days', beginningAgo).valueOf()
        endTime = moment().endOf('day').subtract('days', beginningAgo).valueOf()
        o.query.$or = [
          {startTime: {$gte: startTime, $lte: endTime}},
          {endTime: {$gte: startTime, $lte: endTime}}
        ]

    o.scope = {}
    if startTime?
      o.scope.startTime = startTime
    if endTime?
      o.scope.endTime = endTime

    @aggregateUsagesByParams o, callback

  averageUsagesEachUsers: (query, callback) ->
    o = {}
    o.query = query || {}
    o.map = () ->
      value =
        userId: @userId,
        startTime: if @startTime instanceof Date then @startTime.getTime() else @startTime,
        endTime: if @endTime instanceof Date then @endTime.getTime() else @endTime,
        duration: @duration,
        count: 1

      emit @userId, value

    o.reduce = (key, vals) ->
      reducedValue =
        userId: key,
        startTime: new Date().getTime(),
        endTime: 0,
        duration: 0,
        count: 0

      vals.forEach (val) ->
        startTime = if val.startTime instanceof Date then val.startTime.getTime() else val.startTime
        endTime = if val.endTime instanceof Date then val.endTime.getTime() else val.endTime
        reducedValue.startTime = if startTime? then Math.min reducedValue.startTime, startTime else reducedValue.startTime
        reducedValue.endTime = if endTime? then Math.max reducedValue.endTime, endTime else reducedValue.endTime
        reducedValue.duration += if val.duration? then val.duration else 0
        reducedValue.count += val.count
        return

      return reducedValue
    
    o.finalize = (key, reducedValue) ->
      reducedValue.nomalizedUsageDurationPerDay = reducedValue.duration * ((24*60*60*1000) / (reducedValue.endTime - reducedValue.startTime))
      reducedValue.nomalizedAppChangingCountPerDay = reducedValue.count * ((24*60*60*1000) / (reducedValue.endTime - reducedValue.startTime))
      reducedValue.startTime = new Date(reducedValue.startTime)
      reducedValue.endTime = new Date(reducedValue.endTime)
      return reducedValue

    @mapReduce o, callback

module.exports = new UsageService