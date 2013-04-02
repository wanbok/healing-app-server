mongoose = require 'mongoose'

Forbidden = new mongoose.Schema {
	startTime: { type: Number, required: true },
	duration: { type: Number, required: true },
}

Forbidden.index {startTime: 1}, {unique: true}
# TODO : Validate to avoid overlapping (time-)block instead of unique indexing.

module.exports = Forbidden