mongoose = require 'mongoose'

Survey = new mongoose.Schema {
	surveyId: { type: String, required: true },
	version: { type: String, required: true },
	userId: { type: String, required: true },
	answerTime: { type: Date, default: Date.now },
	answers: String
}

Survey.index {surveyId: 1, version: 1, userId: 1}, {unique: true}

module.exports = mongoose.model 'Survey', Survey