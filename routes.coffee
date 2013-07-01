# Routes
module.exports = ->
	# content negotiation function
	addingFormat = (req, res, next) ->
		req.format = req.route.path.substring(req.route.path.lastIndexOf('.') + 1)
		next()

	# 'Static page' routes
	@get '/', require('./controllers/home').home
	@get '/gcm', require('./controllers/gcm').test
	@get '/reports', require('./controllers/report').report
	@get '/reports.json', addingFormat, require('./controllers/report').report
	@get '/correlate', require('./controllers/report').correlate
	@get '/correlate.json', addingFormat, require('./controllers/report').correlate
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