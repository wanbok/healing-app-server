# Routes
module.exports = ->
	# 'Static page' routes
	@get '/', require('./controllers/home').home
	@resource 'users', require('./controllers/user')