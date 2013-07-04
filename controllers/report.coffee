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

	correlate: (req, res) ->
		UsageService.averageUsagesEachUsers req.query, (err, docs) ->
			if err?
			  console.log err
			switch req.format
				when 'json' then res.json docs
				else res.render 'reports/correlate', {docs: docs, err: err}

module.exports = new ReportController