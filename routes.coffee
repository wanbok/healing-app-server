# Routes
module.exports = ->
	# 'Static page' routes
	@get '/', require('./controllers/home').home
	users = @resource 'users', require('./controllers/user')
	@resource 'apps', require('./controllers/app')
	@resource 'categories', require('./controllers/category')
	@resource 'usages', require('./controllers/usage')
	@resource 'reports', require('./controllers/report')
	@resource 'surveys', require('./controllers/survey')
	@resource 'friendships', require('./controllers/friendship')
	installs = @resource 'installs', require('./controllers/install')

	users.add installs