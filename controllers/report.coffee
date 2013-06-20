UsageService = require '../services/usage'
Usage = require '../models/usage'

# Report model's CRUD controller.
class ReportController 

  # Lists all reports
  report: (req, res) ->
    UsageService.usagesByParams req.query, (err, reports) ->
      switch req.format
        when 'json' then res.json reports
        else res.render 'reports/d3', {reports: reports, err: err}

  surveyCorrelation: (req, res) ->
  	

module.exports = new ReportController