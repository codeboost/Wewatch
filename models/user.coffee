mongoose = require 'mongoose'

UserSchema = new mongoose.UserSchema
	email: String
	name: String
	avatar: String

mongoose.model 'User', UserSchema