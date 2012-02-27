
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

BookmarkItem = new mongoose.Schema
	id_session: ObjectId
	url: String
	position: Number
	length: Number
	thumbnail: String
	title: String

mongoose.model 'VideoBookmark', BookmarkItem