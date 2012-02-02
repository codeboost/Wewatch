
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

PlaylistItem = new mongoose.Schema
	id_session: ObjectId
	url: String
	title: String
	id_user: ObjectId


mongoose.model 'PlaylistItem', PlaylistItem