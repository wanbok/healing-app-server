mongoose = require 'mongoose'

Forbidden = new mongoose.Schema {
	startTime: { type: Number, required: true },
	duration: { type: Number, required: true },
}

# Forbidden.index {startTime: 1}, {unique: true} # This is deprecated because, if this documents is a embedded document, their uniqueness can not be ensured.
# TODO : Validate to avoid overlapping (time-)block instead of unique indexing.

module.exports = Forbidden