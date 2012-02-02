mongoose = require 'mongoose'

ObjectId = mongoose.Schema.ObjectId

SessionSchema = new mongoose.Schema
	title: String
	creator: ObjectId
	url: String

mongoose.model 'WatchSession', SessionSchema
