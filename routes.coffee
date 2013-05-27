# Routes
module.exports = ->
	# 'Static page' routes
	@get '/', require('./controllers/home').home
	@get '/gcm', require('./controllers/gcm').test

	# RESTful
	@resource 'apps', require('./controllers/app')
	@resource 'categories', require('./controllers/category')
	@resource 'usages', require('./controllers/usage')
	@resource 'surveys', require('./controllers/survey')
	@resource 'friendships', require('./controllers/friendship')
	@resource 'reports', require('./controllers/report')

	# Nested by User
	users = @resource 'users', require('./controllers/user')
	installs = @resource 'installs', require('./controllers/install')

	users.add installs