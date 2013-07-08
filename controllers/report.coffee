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

module.exports = new ReportController