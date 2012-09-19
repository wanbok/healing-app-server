global.mongoose = require 'mongoose'
global.db = mongoose.createConnection 'localhost', 'easybus'