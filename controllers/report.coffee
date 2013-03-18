Report = require '../models/report'

# Report model's CRUD controller.
class ReportController 

  # Lists all reports
  index: (req, res) ->
    Report.find {}, (err, reports) ->
      switch req.format
        when 'json' then res.json reports
        else res.render 'reports/index', {reports: reports}

  new: (req, res) ->
    res.render 'reports/new', {report: new Report, errs: null}

  edit: (req, res) ->
    Report.findById req.params.report, (err, report) ->
      if err
        report = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json report
        else res.render 'reports/edit', {report: report, errs: null}

  # Creates new report with data from `req.body.report`
  create: (req, res) ->
    report = new Report req.body.report
    report.save (err, report) ->
      if not err
        res.send report
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets report by id
  show: (req, res) ->
    Report.findById req.params.report, (err, report) ->
      if err
        report = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json report
        else res.render 'reports/show', {report: report}

  # Updates report with data from `req.body.report`
  update: (req, res) ->
    Report.findByIdAndUpdate req.params.report, {"$set":req.body.report}, (err, report) ->
      if not err
        res.send report
      else
        res.send err
        res.statusCode = 500
    
  # Deletes report by id
  destroy: (req, res) ->
    Report.findByIdAndRemove req.params.report, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new ReportController