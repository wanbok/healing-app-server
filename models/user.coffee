mongoose = require 'mongoose'

User = new mongoose.Schema {
	telNumber: { type: String, index: { unique: true }, required: true },
	name: { type: String, required: true },
	birth: Date,
	school: String,
	grade: Number,
	class: String,
	address: String,
	addressForSchool: String,
	followings: Array
}

module.exports = mongoose.model 'User', User