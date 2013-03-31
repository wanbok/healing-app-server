mongoose = require 'mongoose'

Report = new mongoose.Schema {
	userId: { type: String, required: true },
	appPkg: { type: String, required: true },
	totalTime: Number,
	totalForMonth: Number,
	totalForWeek: Number,
	totalForDay: Number
}

Report.index {userId: 1, appPkg: 1}, {unique: true}

module.exports = mongoose.model 'Report', Report