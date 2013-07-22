# Routes
module.exports = ->
	# content negotiation function
	addingFormat = (req, res, next) ->
		req.format = req.route.path.substring(req.route.path.lastIndexOf('.') + 1)
		next()

	# 'Static page' routes
	@get '/', require('./controllers/home').home
	@get '/gcm', require('./controllers/gcm').test
	@get '/user_usage', require('./controllers/report').user_usage
	@get '/user_usage.json', addingFormat, require('./controllers/report').user_usage
	@get '/correlate', require('./controllers/report').correlate
	@get '/correlate.json', addingFormat, require('./controllers/report').correlate
	@get '/track_location', require('./controllers/report').trackLocation
	@get '/track_location.json', addingFormat, require('./controllers/report').trackLocation
	@get '/scoped_report', require('./controllers/report').scopedReport
	@get '/scoped_report.json', addingFormat, require('./controllers/report').scopedReport
	# @get '/reports/survey', require('./controllers/report').surveyCorrelation

	# RESTful
	@resource 'apps', require('./controllers/app')
	@resource 'categories', require('./controllers/category')
	@resource 'usages', require('./controllers/usage')
	@resource 'surveys', require('./controllers/survey')
	@resource 'friendships', require('./controllers/friendship')

	# Nested by User
	users = @resource 'users', require('./controllers/user')
	installs = @resource 'installs', require('./controllers/install')

	users.add installs