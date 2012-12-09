require './fixture'

Phone = mongoDb.model 'Phone', mongoose.Schema {
	tel_number: { type: Number, index: { unique: true }, required: true },
	device_id: { type: String, index: { unique: true }, required: true },
	updated_date: { type: Date, default: Date.now },
}

module.exports = Phone

# iphone = new Phone { tel_number: 123456789, machine_identifier: 'DAFD#@#FJK' }
# iphone.save (err) ->
# 	if err
# 		res.end 'meow'

