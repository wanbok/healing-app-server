require './fixture'

SearchLog = mongoDb.model 'SearchLog', mongoose.Schema {
	expression: { type: String, index: { unique: true }, required: true },
	tcode: { type: String, required: true },
	bang_code: { type: String, required: true },
	heng_code: { type: String, required: true },
	device_id: { type: String, required: true },
	updated_date: { type: Date, default: Date.now },
}

module.exports = SearchLog