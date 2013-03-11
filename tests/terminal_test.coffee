test_helper = require './helper'
should = require('chai').should()
helper = require '../models/helper'

describe 'TerminalHelpr', ->
	describe '#parseInformationBus', ->
		it 'should return timetable-style json result', ->
			str1 = "포천, 도봉산 경유, 수유역 행 3003, 3005번 안내입니다. (2)3005번 버스는 양문을 경유하며*, 첫차는 오전 5시50분이고, 막차는 오후 9시입니다.차량시각은 (3) 오전 5시50분, 6시20분, 6시50분, 7시15분, 7시50분, 8시5분, 8시20분, 8시45분, 9시, 9시30분, 9시45분, 10시20분, 10시45분, 11시10분, 11시45분, 오후 12시10분, 12시45분, 1시10분, 1시45분, 2시10분, 2시45분, 3시, 3시25분, 3시40분, 4시5분, 4시30분, 4시45분, 5시10분, 5시25분, 5시50분, 6시5분, 6시20분, 6시50분, 7시20분, 7시50분, 8시20분, 8시40분, 9시 *로, (5)소요시간은 약 1시간 40분*입니다. 감사합니다."

			rst1 = {
				"source":str1,
				"info": [{
					"title": '3005번 버스는 양문을 경유하며',
					"timetable":{
						"am":[
							{"hour":5,"minutes":[{minute:50}]},
							{"hour":6,"minutes":[{minute:20},{minute:50}]},
							{"hour":7,"minutes":[{minute:15},{minute:50}]},
							{"hour":8,"minutes":[{minute:5},{minute:20},{minute:45}]},
							{"hour":9,"minutes":[{minute:0},{minute:30},{minute:45}]},
							{"hour":10,"minutes":[{minute:20},{minute:45}]},
							{"hour":11,"minutes":[{minute:10},{minute:45}]}],
						"pm":[
							{"hour":12,"minutes":[{minute:10},{minute:45}]},
							{"hour":1,"minutes":[{minute:10},{minute:45}]},
							{"hour":2,"minutes":[{minute:10},{minute:45}]},
							{"hour":3,"minutes":[{minute:0},{minute:25},{minute:40}]},
							{"hour":4,"minutes":[{minute:5},{minute:30},{minute:45}]},
							{"hour":5,"minutes":[{minute:10},{minute:25},{minute:50}]},
							{"hour":6,"minutes":[{minute:5},{minute:20},{minute:50}]},
							{"hour":7,"minutes":[{minute:20},{minute:50}]},
							{"hour":8,"minutes":[{minute:20},{minute:40}]},
							{"hour":9,"minutes":[{minute:0}]}]},
					"spendingTime": '소요시간은 약 1시간 40분'}]}

			str2 = " 대구고속 안내입니다. (2)[화, 수, 목요일]*, 차량시각은 (3) 오전 7시[화, 수, 목요일], 10시20분, 오후 12시50분, 3시10분, 7시*이고, (2)[금, 토, 일, 월요일]*, 차량시각은 (3) 오전 7시[금, 토, 일, 월요일], 10시20분, 오후 12시50분, 3시10분, 5시40분, 7시*로, (5)요금은 25,600원이고, 소요시간은 약 4시간 10분*입니다. 감사합니다."
			str2_2 = " 대구고속 안내입니다. (@)(3) 오전 7시, 10시20분, 오후 12시50분, 3시10분, 7시*이고, (2)[화, 수, 목요일]*, 차량시각은 (@)(2)[금, 토, 일, 월요일]*, 차량시각은 (3) 오전 7시, 10시20분, 오후 12시50분, 3시10분, 5시40분, 7시*로, (5)요금은 25,600원이고, 소요시간은 약 4시간 10분*입니다. 감사합니다."

			rst2 = {
				"source":str2,
				"info":[{
					"title":"[화, 수, 목요일]",
					"timetable":{
						"am":[
							{"hour":7,"minutes":[{"minute":0, message: "화, 수, 목요일"}]},
							{"hour":10,"minutes":[{"minute":20}]}],
						"pm":[
							{"hour":12,"minutes":[{"minute":50}]},
							{"hour":3,"minutes":[{"minute":10}]},
							{"hour":7,"minutes":[{"minute":0}]}]}}, {
					"title":"[금, 토, 일, 월요일]",
					"timetable":{
						"am":[
							{"hour":7,"minutes":[{minute:0, message: "금, 토, 일, 월요일"}]},
							{"hour":10,"minutes":[{minute:20}]}],
						"pm":[
							{"hour":12,"minutes":[{minute:50}]},
							{"hour":3,"minutes":[{minute:10}]},
							{"hour":5,"minutes":[{minute:40}]},
							{"hour":7,"minutes":[{minute:0}]}]},
					"spendingTime":"요금은 25,600원이고, 소요시간은 약 4시간 10분"}]}

			rst2_2 = {
				"source":str2_2,
				"info":[{
					"timetable":{
						"am":[
							{"hour":7,"minutes":[{"minute":0}]},
							{"hour":10,"minutes":[{"minute":20}]}],
						"pm":[
							{"hour":12,"minutes":[{"minute":50}]},
							{"hour":3,"minutes":[{"minute":10}]},
							{"hour":7,"minutes":[{"minute":0}]}]},
					"title":"[화, 수, 목요일]",}, {
					"title":"[금, 토, 일, 월요일]",
					"timetable":{
						"am":[
							{"hour":7,"minutes":[{minute:0}]},
							{"hour":10,"minutes":[{minute:20}]}],
						"pm":[
							{"hour":12,"minutes":[{minute:50}]},
							{"hour":3,"minutes":[{minute:10}]},
							{"hour":5,"minutes":[{minute:40}]},
							{"hour":7,"minutes":[{minute:0}]}]},
					"spendingTime":"요금은 25,600원이고, 소요시간은 약 4시간 10분"}]}

			str3 = "부산고속 안내입니다.차량시각은 (3) 오전 7시30분, 10시10분, 오후 12시, 2시, 4시30분, 6시30분 *이고, (5)요금은 27,400원이며, 소요시간은 약 5시간*입니다. 감사합니다."
			rst3 = {
				"source":"부산고속 안내입니다.차량시각은 (3) 오전 7시30분, 10시10분, 오후 12시, 2시, 4시30분, 6시30분 *이고, (5)요금은 27,400원이며, 소요시간은 약 5시간*입니다. 감사합니다.",
				"info":[{
					"timetable":{
						"am":[
							{"hour":7,"minutes":[{minute:30}]},
							{"hour":10,"minutes":[{minute:10}]}],
						"pm":[
							{"hour":12,"minutes":[{minute:0}]},
							{"hour":2,"minutes":[{minute:0}]},
							{"hour":4,"minutes":[{minute:30}]},
							{"hour":6,"minutes":[{minute:30}]}]},
					"spendingTime":"요금은 27,400원이며, 소요시간은 약 5시간"}]}

			console.log "str1 : " + JSON.stringify(helper.parseInformationBus(str1)) + "\r\nrst1 : " + JSON.stringify(rst1) + "\r\n"
			console.log "str2 : " + JSON.stringify(helper.parseInformationBus(str2)) + "\r\nrst2 : " + JSON.stringify(rst2)
			console.log "str3 : " + JSON.stringify(helper.parseInformationBus(str2)) + "\r\nrst3 : " + JSON.stringify(rst2)

			JSON.stringify(helper.parseInformationBus(str1)).should.equal JSON.stringify(rst1)
			JSON.stringify(helper.parseInformationBus(str2)).should.equal JSON.stringify(rst2)
			JSON.stringify(helper.parseInformationBus(str2_2)).should.equal JSON.stringify(rst2_2)
			JSON.stringify(helper.parseInformationBus(str3)).should.equal JSON.stringify(rst3)