# Routes
module.exports = ->
	# 'Static page' routes
	@get '/', require('./controllers/home').home
	@resource 'users', require('./controllers/user')
	@resource 'apps', require('./controllers/app')
	@resource 'categories', require('./controllers/category')
	@resource 'usages', require('./controllers/usage')
	@resource 'reports', require('./controllers/report')
	@resource 'surveys', require('./controllers/survey')
	@resource 'friendships', require('./controllers/friendship')
	@resource 'installs', require('./controllers/installs')