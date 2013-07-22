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
      value =
        userId: @userId,
        appPkg: @appPkg,
        duration: @duration,
        urlInfo: @urlInfo

      if startTime? and startTime > value.startTime   # cut off before focus time
        value.duration -= Math.abs(startTime - value.startTime)
        value.startTime = startTime

      if endTime? and endTime < value.endTime         # cut off after focus time
        value.duration -= Math.abs(endTime - value.endTime)
        value.endTime = endTime

      emit @appPkg, value

    o.reduce = (k, vals) ->
      reducedValue =
        userId: vals[0].userId,
        appPkg: vals[0].appPkg,
        duration: 0,
        urlInfo: vals[0].urlInfo

      for val in vals
        reducedValue.duration += val.duration
        unless val.urlInfo is null
          if reducedValue.urlInfo is null
            reducedValue.urlInfo = val.urlInfo
          else
            reducedValue.urlInfo = reducedValue.urlInfo + ", " + val.urlInfo

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

  aggregateUsagesForScopedReport: (query, callback) ->
    o = {}
    o.query = query || {}
    o.map = () ->
      value =
        userId: @userId,
        startTime: if @startTime instanceof Date then @startTime.getTime() else @startTime,
        endTime: if @endTime instanceof Date then @endTime.getTime() else @endTime,
        duration: @duration,
        duration2: 0,
        durations: {},
        count: 1

      emit @userId, value

    o.reduce = (k, vals) ->
      reducedValue =
        userId: vals[0].userId,
        startTime: vals[0].startTime,
        endTime: vals[vals.length - 1].endTime,
        duration: 0,
        duration2: 0,
        durations: {},
        count: 0

      vals.forEach (val) ->
        hour = 60 * 60 * 1000
        # localtime = new Date().getTimezoneOffset() * 60 * 1000
        # val.startTime = if val.startTime instanceof Date then val.startTime.getTime() else val.startTime
        # val.endTime = if val.endTime instanceof Date then val.endTime.getTime() else val.endTime
        next = val.startTime
        fullDuration = val.duration
        reducedValue.duration2 += (val.endTime - val.startTime)
        while fullDuration > 0
          previous = next
          next = previous - (previous % hour) + hour
          duration = Math.min(fullDuration, next - previous)
          keyDate = new Date(previous)
          key = new String(keyDate.getFullYear())
          if (keyDate.getMonth() + 1) < 10 then key += "0"          # 한자리수 월단위를 0x로. (e.g. 2월 => 02)
          key += keyDate.getMonth() + 1
          if keyDate.getDate() < 10 then key += "0"                 # 한자리수 일단위를 0x로. (e.g. 5일 => 05)
          key += keyDate.getDate()
          if keyDate.getHours() < 10 then key += "0"                # 한자리수 시단위를 0x로. (e.g. 5시 => 05)
          key += keyDate.getHours()
          reducedValue.durations[key] = reducedValue.durations[key] || 0
          reducedValue.durations[key] += duration
          reducedValue.duration += duration
          fullDuration -= duration

        return

      return reducedValue

    @mapReduce o, callback

module.exports = new UsageService