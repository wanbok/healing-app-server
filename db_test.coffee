mysql = require 'mysql'

client = mysql.createConnection #'mysql://na2:arsna2@nadata.codns.com:6612/na2'
  host     : 'nadata.codns.com',
  port     : 6612,
  user     : 'root',
  password : '12341234'
  database : 'na2'

client.connect()

client.query 'USE na2', (error, results) =>
  if(error)
    console.log("데이터베이스 접속 실패: " + error)
    return
  console.log "na2 데이터베이스에 접속하였습니다."
  getData client
 
# ClientReady = (client) =>
#   values = ['Leo', 'Lee', '만나서 반가워요!']
#   client.query "INSERT INTO MyTable SET firstname=?, lastname=?, message =?", values, (error, results) =>
#     if(error)
#       console.log("데이터베이스 입력 실패: " + error)
#       client.end()
#       return
#     console.log(results.affectedRows + "열 추가하였습니다.")
#     console.log("ID 추가하였습니다: " + results.insertId)
#   getData(client)
 
getData = (client) =>
  client.query "SELECT * FROM na2_admin", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      client.end()
      return

    if(results.length > 0)
      firstResult = results[0]
      console.log firstResult
      # console.log('이름: ' + firstResult['firstname']);
      # console.log('성: ' + firstResult['lastname']);
      # console.log('메세지: ' + firstResult['message']);
  client.end()
  console.log("연결이 닫혔습니다.")