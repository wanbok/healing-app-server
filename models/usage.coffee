mongoose = require 'mongoose'

Usage = new mongoose.Schema {
	userTelNumber: { type: String, index: true, required: true },
	appIdentifier: { type: String, index: true, required: true },
	startedAt: { type: Date, index: true, default: Date.now },
	endedAt: Date,
	latitude: Number,
	longitude: Number,
	host: String
}

# This is not required. Because Usage is stackable data's schema
# Usage.index {userTelNumber: 1, appIdentifier: 1, startedAt: 1}, {unique: true}

module.exports = mongoose.model 'Usage', Usage