
# Module dependencies.

express = require 'express'
require 'express-namespace'

path = require 'path'
GLOBAL._ = require 'underscore'

app = module.exports = express()

port = ->
  if (app.settings.env is 'production')
    8080
  else
    3030
app.configure ->
  app.set 'port', port()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser('IDONTHAVESECRET')
  app.use express.session()
  app.use app.router
  app.use require('stylus').middleware(__dirname + '/public')
  app.use express.static(path.join(__dirname, 'public'))

app.configure 'development', ->
  app.use(express.errorHandler());

# Routes
require('./apps/terminal/routes')(app)
require('./apps/notifier/routes')(app)
require('./apps/phone/routes')(app)
require('./apps/searchlog/routes')(app)
require('./apps/payment/routes')(app)

app.listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

require('./mysql_configure')