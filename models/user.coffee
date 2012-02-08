mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
	email: String
	name: String
	avatar: String
	sid: String


SessionUser = new mongoose.Schema
	id_user: mongoose.Schema.ObjectId
	name: String
	email: String
	avatar: String
	sid: String	
	id_session: mongoose.Schema.ObjectId


mongoose.model 'SessionUser', SessionUser
mongoose.model 'User', UserSchema