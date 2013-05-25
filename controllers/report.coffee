UsageService = require '../services/usage'
Usage = require '../models/usage'

# Report model's CRUD controller.
class ReportController 

  # Lists all reports
  report: (req, res) ->
    # Usage.find {}, (err, docs) ->
    #   if err
    #     res.json err
    #   else
    #     res.json docs
    UsageService.usagesByParams req.query, (err, results) ->
      res.json results

module.exports = new ReportController