io = require 'socket.io'
express = require 'express'


exports.Session = class Session
	constructor: (@id) ->

	addUser: (socket) ->
	
	removeUser: (socket) ->
		
			


exports.SessionManager = class SessionManager
	
	constructor: (app) ->
		SM = this
		@io = io.listen app
		@io.set 'authorization', (data, callback) ->
			res = {}
			express.cookieParser() data, res, ->
				sid = data.cookies['connect.sid']
				return callback('Error, not authorized', false) unless sid
				SM.authorizeUser sid, (err, user) ->
					return callback(err, false) if err
					#store user auth in the socket.handshake structure
					data.user = user
					return callback(null, true)
		@io.sockets.on 'connection', (socket) ->
			SM.userConnected socket

			socket.on 'disconnect', ->
				SM.userDisconnected socket
			
			socket.on 'join', (sessionId, callback) =>
				SM.userJoin sessionId, socket, callback

	
	createSession: (sessionData, callback) ->
		

	authorizeUser: (sid, callback) ->
		#override, lookup real user by sid and respond with user record (json)
		callback null, {sid: sid}

	userConnected: (socket) ->

	userDisconnected: (socket) ->

	userJoin: (sessionId, socket, callback) ->
		callback null