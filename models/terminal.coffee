helper = require './helper'

terminal = {}

terminal.search = (search, callback) => 
  mysqlDb.query "SELECT * FROM na2_admin WHERE tname like '%#{search}%'", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        latitude: result['gps_info1'],
        longitude: result['gps_info2'],
        regdate: result['regdate']}

    callback null, results_for_return

terminal.start_region = (callback) =>
  results_for_return = [
    {acode: "02", region_name: "강원도"},
    {acode: "01", region_name: "경기도"},
    {acode: "04", region_name: "경상남도"},
    {acode: "03", region_name: "경상북도"},
    {acode: "15", region_name: "광주"},
    {acode: "13", region_name: "대구"},
    {acode: "16", region_name: "대전"},
    {acode: "12", region_name: "부산"},
    {acode: "10", region_name: "서울"},
    {acode: "14", region_name: "울산"},
    {acode: "11", region_name: "인천"},
    {acode: "06", region_name: "전라남도"},
    {acode: "05", region_name: "전라북도"},
    {acode: "09", region_name: "제주도"},
    {acode: "08", region_name: "충청남도"},
    {acode: "07", region_name: "충청북도"}
  ]

  callback null, results_for_return

terminal.start_terminal = (acode, callback) =>
  mysqlDb.query "SELECT * FROM na2_admin WHERE acode = '#{acode}'", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        acode: result['acode'],
        bang_code: result['bang_code'],
        bang_name: result['bang_name'],
        regdate: result['regdate']}

    callback null, results_for_return

    
terminal.all = (callback) => 
  mysqlDb.query "SELECT * FROM na2_admin", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      console.log {config: mysqlDb.config, result: result}
      continue if result['tcode'] is '000'
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        acode: result['acode'],
        latitude: result['gps_info1'],
        longitude: result['gps_info2'],
        regdate: result['regdate']}

    callback null, results_for_return

terminal.arrive_region = (tcode, callback) =>
  mysqlDb.query "SELECT * FROM na2_bang WHERE tcode = '#{tcode}'", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        bang_code: result['bang_code'],
        bang_name: result['bang_name'],
        regdate: result['regdate']}

    callback null, results_for_return

terminal.arrive_terminal = (tcode, bang_code, callback) =>
  mysqlDb.query "SELECT * FROM na2_heng WHERE tcode = '#{tcode}' AND bang_code = '#{bang_code}'", (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        bang_code: result['bang_code'],
        bang_name: result['bang_name'],
        heng_code: result['heng_code'],
        heng_name: result['heng_name'],
        regdate: result['regdate']}

    callback null, results_for_return

terminal.timetable = (tcode, bang_code, heng_code, wcode, callback) =>
  if typeof wcode is 'undefined' or wcode is null or wcode is ''
    wcode = new Date().getDay() + 1
    # console.log "Default day : #{wcode}, today : #{new Date()}"

  select_query = "SELECT * FROM na2_bustime WHERE tcode = '#{tcode}' AND bang_code = '#{bang_code}' AND heng_code = '#{heng_code}' AND wcode = '#{wcode}'"
  mysqlDb.query select_query, (error, results, fields) =>
    if(error)
      console.log("데이터베이스 조회 실패: " + error)
      callback error, null

    results_for_return = []
    for result in results
      results_for_return.push {
        tcode: result['tcode'],
        tname: result['tname'],
        bang_code: result['bang_code'],
        bang_name: result['bang_name'],
        heng_code: result['heng_code'],
        heng_name: result['heng_name'],
        bustype: result['bustype'],
        wcode: result['wcode'],
        content: helper.parseInformationBus(result['content']),
        regdate: result['regdate']}

    callback null, results_for_return

terminal.sampleTimetable = (callback) =>
  sample_source = '(1)예비용 첫번째이올시다.*
    (2)우등고속 차량 시*은
    (3)오전7시30분, 8시45분[예아], 10시20분, 11시50분, 
    오후 12시30분, 1시 30분[예아], 2시35분[gg], 4시50분, 7시55분,*
    (4)배차간격은 1시간50분에서 2시20분입니다.*
    (5)소요시간은 약 2시간 50분입니다.*
    (6)요금은 23000원*이고
    (7)서울, 대전, 대구, 부산, 찍고 아항*
    (8)첫번째 아래쪽 예비 1번*
    (9)첫번째 아래쪽 예비 2번*
    (10)첫번째 아래(?)쪽 예비(?)(?) 3번*
    (11)첫번째 아래(??)쪽 예비 4번*
    (12)첫번째 아래쪽 예비 5번*
    (13)첫번째 아래쪽 예비 6번*
    (14)첫번째 아래쪽 예비 7번*
    (15)첫번째 아래쪽 예비 8번*
    (1)예비용 두번째이올시다.*
    (2)일반 차량시각*은
    (3)오전7시30분, 8시45분, 10시20분, 11시50분, 
    오후 12시30분, 1시 30분, 2시35분, 4시50분[ㅇㅇ], 7시55분,*
    (4)배차간격은 1시간50분에서 2시20분입니다.*
    (5)소요시간은 약 2시간 50분입니다.*
    (6)요금은 23000원*
    (7)마드리드, 몬트리올*
    (8)두번째 아래쪽 예비 1번*
    (1)세번째 예비용이다*
    (2)무정차 차량시각*은
    (3)오전7시30분, 8시45분, 10시20분, 11시50분, 
    오후 12시30분, 1시 30분, 2시35분[그래], 4시50분, 7시55분,*
    (4)배차간격은 1시간50분에서 2시20분입니다.*
    (5)요금은 23000원이고 소요시간은 약 2시간 50분입니다.*
    (2)안양,부천, 천안 경유 차량 시각*은
    (3)오전7시30분, 8시45분, 10시20분, 11시50분, 
    오후 12시30분, 1시 30분, 2시35분, 4시50분, 7시55분,*
    (4)배차간격은 1시간50분에서 2시20분입니다,*
    (5)소요시간은 약 2시간 50분입니다.*
    (6)요금은 23000원이고*
    (7)도쿄, 아테네*
    (8)세번째 아래쪽 예비용 1번*
    (9)세번째 아래쪽 예비용 2번*
    (10)세번째 아래쪽 예비용 3번*
    (11)세번째 아래쪽 예비용 4번*
    (12)세번째 아래쪽 예비용 5번*'
  aResult = {
    tcode: '000',
    tname: '샘플출발터미널',
    bang_code: '00',
    bang_name: '안드로메다',
    heng_code: '01',
    heng_name: '샘플도착터미널',
    bustype: '1',
    wcode: new Date().getDay() + 1,
    content: helper.parseInformationBus(sample_source),
    regdate: new Date().toISOString()}
  result = [aResult]
  callback null, result

module.exports = terminal

# mysqlDb.query 'USE na2', (error, results) =>
#   if(error)
#     console.log("데이터베이스 접속 실패: " + error)
#     return
#   console.log "na2 데이터베이스에 접속하였습니다."
#   getData mysqlDb
 
# mysqlDbReady = (mysqlDb) =>
#   values = ['Leo', 'Lee', '만나서 반가워요!']
#   mysqlDb.query "INSERT INTO MyTable SET firstname=?, lastname=?, message =?", values, (error, results) =>
#     if(error)
#       console.log("데이터베이스 입력 실패: " + error)
#       mysqlDb.end()
#       return
#     console.log(results.affectedRows + "열 추가하였습니다.")
#     console.log("ID 추가하였습니다: " + results.insertId)
#   getData(mysqlDb)
 
# getData = (mysqlDb) =>
#   mysqlDb.query "SELECT * FROM na2_admin", (error, results, fields) =>
#     if(error)
#       console.log("데이터베이스 조회 실패: " + error)
#       mysqlDb.end()
#       return

#     if(results.length > 0)
#       firstResult = results[0]
#       console.log firstResult
#       # console.log('이름: ' + firstResult['firstname']);
#       # console.log('성: ' + firstResult['lastname']);
#       # console.log('메세지: ' + firstResult['message']);
#   mysqlDb.end()
#   console.log("연결이 닫혔습니다.")
