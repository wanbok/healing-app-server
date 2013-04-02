mongoose = require 'mongoose'
Forbidden = require 'forbidden'

Install = new mongoose.Schema {
	userId: { type: String, required: true },
	appPkg: { type: String, required: true },
	forbiddens : [Forbidden]
}

Install.index {userId: 1, appPkg: 1}, {unique: true}

module.exports = mongoose.model 'Install', Install