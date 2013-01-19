global.mysql = require 'mysql'

global.mysqlDb = mysql.createConnection #'mysql://na2:arsna2@nadata.codns.com:6612/na2'
  host     : 'nadata.codns.com',
  port     : 6612,
  # charset  : 'EUCKR_KOREAN_CI',
  user     : 'na2',
  password : 'arsna2',
  database : 'na2'

handleDisconnect = (connection) ->
  connection.on 'error', (err) ->
    console.log ('Connection lost is raised! error code : ' + err.code)
    if (!err.fatal)
      return

    if (err.code isnt 'PROTOCOL_CONNECTION_LOST')
      throw err

    console.log('Re-connecting lost connection: ' + err.stack)

    global.mysqlDb = mysql.createConnection(global.mysqlDb.config)
    handleDisconnect(global.mysqlDb)
    global.mysqlDb.connect()

handleDisconnect(global.mysqlDb)