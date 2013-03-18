mongoose = require 'mongoose'

Friendship = new mongoose.Schema {
	followerTelNumber: { type: String, required: true },
	followingTelNumber: { type: String, required: true },
	isPaired: { type: Boolean, default: false },
	needAsk: { type: Boolean, default: false }
}

Friendship.index {followerTelNumber: 1, followingTelNumber: 1}, {unique: true}

module.exports = mongoose.model 'Friendship', Friendship