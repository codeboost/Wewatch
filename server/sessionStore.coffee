mongoose = require 'mongoose'
express = require 'express'

class exports.SessionStore extends express.session.Store
	constructor: ->
		SessionSchema = new mongoose.Schema
			sid: String
			session: {}
			
		@sessionModel = mongoose.model 'Session', SessionSchema

	get: (sid, fn) ->
		@sessionModel.findOne sid: sid, (err, docs) ->
			if err || !docs then return fn?()
			session = docs.toObject()
			return fn?(err, session.session)
	
	set: (sid, session, fn) ->
		#console.log 'Set session : ' + sid
		@sessionModel.update {sid: sid}, 
			sid: sid
			session: session
		, {upsert: true}, (err, sess) ->
				fn?(err)
			
			
	
	destroy: (sid, fn) ->
		@sessionModel.remove sid:sid, (err) ->
			console.dir err
	
	all: (fn) ->
		console.log 'Alll'
		
	clear: (fn) ->
		console.log 'Clear'
		
	length: (fn) ->
		console.log 'Length'