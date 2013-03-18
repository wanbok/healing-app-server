mongoose = require 'mongoose'

Survey = new mongoose.Schema {
	identifier: { type: String, required: true },
	version: { type: String, required: true },
	userTelNumber: { type: String, required: true },
	answeredAt: { type: Date, default: Date.now },
	answers: Array
}

Survey.index {identifier: 1, version: 1, userTelNumber: 1}, {unique: true}

module.exports = mongoose.model 'Survey', Survey