should = require('chai').should()
helper = require '../apps/terminal/helper'

describe 'TerminalHelpr', ->
	describe '#parseTimeTableFromString', ->
		it 'should return timetable-style json result', ->
			str1 = "강남터미널 안내입니다.포천, 장현을 경유하며, 차량시각은 (@) 오전 7시45분, 8시25분, 9시45분, 10시35분, 11시45분, 오후 2시25분, 3시25분, 4시55분, 5시, 6시45분, 8시5분 (*)으로, 소요시간은 약 1시간 50분입니다. 감사합니다."
			str2 = "동서울 직행 3000번 안내입니다. 포천, 내촌, 장현을 경유하며, 첫차는 오전 5시50분이고,막차는 오후 9시40분입니다.차량시각은 (@) 오전 5시50분, 6시40분, 7시20분, 8시, 8시40분, 9시10분, 9시40분, 10시10분, 10시50분, 11시30분,
				오후 12시10분, 12시50분, 1시30분, 2시10분, 2시50분, 3시30분, 4시10분, 4시50분, 5시20분, 6시, 6시40분, 7시20분, 8시, 8시40분, 9시10분, 9시40분 (*)으로 소요시간은 약 1시간 40분입니다. 감사합니다."
			rst1 = [{
				timetable:{
					am: [
							{hour: 7,	minutes: [45]},
							{hour: 8, minutes: [25]},
							{hour: 9, minutes: [45]},
							{hour: 10, minutes: [35]},
							{hour: 11, minutes: [45]}
					],
					pm: [
							{hour: 2, minutes: [25]},
							{hour: 3, minutes: [25]},
							{hour: 4, minutes: [55]},
							{hour: 5, minutes: [0]},
							{hour: 6, minutes: [45]},
							{hour: 8, minutes: [5]}
					]
				}
			}]
			rst2 = [{
				timetable: {
					am: [
							{hour: 5,	minutes: [50]},
							{hour: 6, minutes: [40]},
							{hour: 7, minutes: [20]},
							{hour: 8, minutes: [0, 40]},
							{hour: 9, minutes: [10, 40]},
							{hour: 10, minutes: [10, 50]},
							{hour: 11, minutes: [30]}
					],
					pm:	[
							{hour: 12, minutes: [10, 50]},
							{hour: 1, minutes: [30]},
							{hour: 2, minutes: [10, 50]},
							{hour: 3, minutes: [30]},
							{hour: 4, minutes: [10, 50]},
							{hour: 5, minutes: [20]},
							{hour: 6, minutes: [0, 40]},
							{hour: 7, minutes: [20]},
							{hour: 8, minutes: [0, 40]},
							{hour: 9, minutes: [10, 40]}
					]
				}
			}]
			console.log "str1 : " + JSON.stringify(helper.parseTimeTableFromString(str1)) + "\r\nrst1 : " + JSON.stringify(rst1) + "\r\n"
			console.log "str2 : " + JSON.stringify(helper.parseTimeTableFromString(str2)) + "\r\nrst2 : " + JSON.stringify(rst2)

			JSON.stringify(helper.parseTimeTableFromString(str1)).should.equal JSON.stringify(rst1)
			JSON.stringify(helper.parseTimeTableFromString(str2)).should.equal JSON.stringify(rst2)