
# Home controller
#
# Serves the application home page
class SessionController

	# /
	#
	# @param request
	# @param response
	login: (request, response) ->
		response.render "session/login",
		#response.redirect '/session/new'

	auth: (request, response) ->
		request.session.user = request.body.username 
		console.log  request.body.username 
		if request.body.username isnt 'admin'
			response.render "index",
				title: 'Login Failed'
		else
			response.render "index",
				title: 'Login Success'

	
module.exports = new SessionController
