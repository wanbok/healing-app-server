UsageService = require '../services/usage'
Usage = require '../models/usage'

# Report model's CRUD controller.
class ReportController 

	# Lists all reports
	report: (req, res) ->
		if req.query.userId?
			UsageService.usagesByParams req.query, (err, reports) ->
				switch req.format
					when 'json' then res.json reports
					else res.render 'reports/d3', {reports: reports, err: err}
		else
			UsageService.averageUsagesEachUsers (err, reports) ->
				switch req.format
					when 'json' then res.json reports
					else res.render 'reports/d3', {reports: reports, err: err}

module.exports = new ReportController