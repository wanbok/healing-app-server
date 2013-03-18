mongoose = require 'mongoose'

Report = new mongoose.Schema {
	userTelNumber: { type: String, required: true },
	appIdentifier: { type: String, required: true },
	totalTime: Number,
	totalForMonth: Number,
	totalForWeek: Number,
	totalForDay: Number
}

Report.index {userTelNumber: 1, appIdentifier: 1}, {unique: true}

module.exports = mongoose.model 'Report', Report