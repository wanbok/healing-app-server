mongoose = require 'mongoose'

App = new mongoose.Schema {
	identifier: { type: String, index: { unique: true }, required: true },
	name: { type: String, required: true },
	categories: Array
}

module.exports = mongoose.model 'App', App