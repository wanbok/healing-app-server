
# Home controller
#
# Serves the application home page
class HomeController

	# /
	#
	# @param request
	# @param response
	home: (request, response) ->
		response.render "index",
			title: 'Smartphone Addiction Management System!'

module.exports = new HomeController
