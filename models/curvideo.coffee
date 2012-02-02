
mongoose = require 'mongoose'

CurVideoSchema = new mongoose.Schema
	url: String
	position: Number
	paused: Boolean
	owner: mongoose.Schema.ObjectId
	id_session: mongoose.Schema.ObjectId


mongoose.model 'CurVideo', CurVideoSchema
