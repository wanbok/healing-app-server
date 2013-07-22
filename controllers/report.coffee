UsageService = require '../services/usage'
Usage = require '../models/usage'

# Report model's CRUD controller.
class ReportController 

  # Lists all reports
  user_usage: (req, res) ->
    if req.format isnt 'json' && (_.isEmpty(req.query) || _.isUndefined(req.query.userId))
      Usage.distinct 'userId', {}, (err, docs) ->
        if err?
          console.log err
        res.render 'reports/user_usage', {links: docs, err: err}
    else
      UsageService.usagesByParams req.query, (err, docs) ->
        switch req.format
          when 'json' then res.json docs
          else res.render 'reports/user_usage', {reports: docs, err: err}

  correlate: (req, res) ->
    switch req.format
      when 'json'
        UsageService.averageUsagesEachUsers req.query, (err, docs) ->
          if err?
            console.log err
          res.json docs
      else res.render 'reports/correlate'

  trackLocation: (req, res) ->
    if _.isEmpty(req.query) || _.isUndefined(req.query.userId)
      Usage.distinct 'userId', {}, (err, docs) ->
        if err?
          console.log err
        switch req.format
          when 'json' then res.json docs
          else res.render 'reports/track_location', {links: docs, err: err}
    else
      Usage.find req.query, null, {sort: {startTime: -1}}, (err, docs) ->
        if err?
          console.log err
        switch req.format
          when 'json' then res.json docs
          else res.render 'reports/track_location', {docs: docs, err: err}

  scopedReport: (req, res) ->
    switch req.format
      when 'json'
        UsageService.aggregateUsagesForScopedReport req.query, (err, docs) ->
          if err?
            console.log err
          res.json docs
      else res.render 'reports/scoped_report'

module.exports = new ReportController