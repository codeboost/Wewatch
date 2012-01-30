mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
	email: String
	name: String
	avatar: String
	sid: String

mongoose.model 'User', UserSchema