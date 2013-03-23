
# Dependencies
express = require 'express'
assets = require 'connect-assets'
mongoose = require 'mongoose'

module.exports = ->
	baseDir = @set 'baseDir'

	# Define Port
	@port = process.env.PORT or process.env.VMC_APP_PORT or 3000

	@set 'views', baseDir + '/views'
	@set 'view engine', 'jade'
	@set 'view options', {layout: true}
	
	# DB Setting.
	# db_config = "mongodb://#{config.DB_USER}:#{config.DB_PASS}@#{config.DB_HOST}:#{config.DB_PORT}/#{config.DB_NAME}"
	# mongoose.connect db_config
	mongoose.connect 'mongodb://localhost/healing'

	# Add Connect Assets.
	@use assets()
	# Set the public folder as static assets.
	@use express.static(baseDir + '/public')
	
	# Allow parsing of request bodies and '_method' parameters
	@use express.bodyParser()
	@use express.methodOverride()
	
	# Enable cookies
	@use express.cookieParser('your secret here')
	
	# Mount application routes
	@use @router

	# Helper
	require('../helpers/helper')(@)
	@use @helpers

	# Routin works
	