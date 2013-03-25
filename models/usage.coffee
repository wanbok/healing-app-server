mongoose = require 'mongoose'

Usage = new mongoose.Schema {
	userId: { type: String, index: true, required: true },
	appPkg: { type: String, index: true, required: true },
	startTime: { type: Date, index: true, default: Date.now },
	duration: Number,
	latitude: Number,
	longitude: Number,
	urlInfo: String
}

# This is not required. Because Usage is stackable data's schema
# Usage.index {userTelNumber: 1, appIdentifier: 1, startedAt: 1}, {unique: true}

module.exports = mongoose.model 'Usage', Usage