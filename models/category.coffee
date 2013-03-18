mongoose = require 'mongoose'

Category = new mongoose.Schema {
	name: { type: String, index: { unique: true }, required: true },
	apps: Array
}

module.exports = mongoose.model 'Category', Category