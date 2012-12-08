global.mysql = require 'mysql'

global.client = mysql.createConnection #'mysql://na2:arsna2@nadata.codns.com:6612/na2'
  host     : 'nadata.codns.com',
  port     : 6612,
  user     : 'na2',
  password : 'arsna2',
  database : 'na2'

handleDisconnect = (connection) ->
  connection.on 'error', (err) ->
    if (!err.fatal)
      return

    if (err.code isnt 'PROTOCOL_CONNECTION_LOST')
      throw err

    console.log('Re-connecting lost connection: ' + err.stack)

    global.client = mysql.createConnection(global.client.config)
    handleDisconnect(global.client)
    global.client.connect()

handleDisconnect(global.client)