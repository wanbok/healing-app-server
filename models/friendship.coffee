mongoose = require 'mongoose'

Friendship = new mongoose.Schema {
	followerId: { type: String, required: true },
	followingId : { type: String, required: true },
	isPaired: { type: Boolean, default: false },
	needAsk: { type: Boolean, default: false }
}

Friendship.index {followerId: 1, followingId: 1}, {unique: true}

module.exports = mongoose.model 'Friendship', Friendship