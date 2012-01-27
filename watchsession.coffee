
Session = require './session'
Skull = require 'skull.io'
_ = require 'underscore'

g_SessionId = 1234
g_UserId = 4585

class UserModel extends Skull.Model
	constructor: ->
		@users = {}	

	read: (filter, callback) ->
		callback null, _.toArray @users

	create: (data, callback, socket) ->
		@users[data.id] = data
		callback? null, data
		@emit 'create', data, socket

	update: (data, callback, socket) ->
		@users[data.id] = data
		callback? null, data
		@emit 'update', data, socket

	delete: (data, callback, socket) ->
		delete @users[data.id]
		callback? null, data
		@emit 'delete', data, socket
	
class VideoModel extends Skull.Model
	constructor: ->
		@video = {
			url: ''
			state: -1
			position: 0
			id: 1
			owner: ''
		}

	read: (filter, callback, socket) ->
		console.log 'Video Read: ', @video
		callback null, @video
			
	update: (data, callback, socket) ->
		console.log 'Video update', data
		@video = data
		callback null, data
		@emit 'update', data, socket

class WatchSession extends Session.Session
	constructor: (@id, @ns) ->
		super
		@users = new UserModel
		@video = new VideoModel
		@ns.addModel '/users', @users
		@ns.addModel '/video', @video
		console.log 'Created watch session ', @id

	addUser: (socket, callback) ->
		user = socket.handshake.user
		@users.create user, null, socket

		console.log 'Add user %s to session %s', user.id, @id

		socket.on 'disconnect', => 
			console.log 'User disconnected'
			@users.delete user, null, socket
		
		callback null

	bootstrap: (callback) ->
		ret = 
			users: _.toArray @users.users
			video: @video.video
		callback null, ret


exports.Server = class WatchSessionManager extends Session.SessionManager
	constructor: ->
		super
		@sessions = {}
		@users = {}
		@activeUsers = {}
		@skullServer = new Skull.Server @io

	authorizeUser: (sid, callback) ->
		console.log 'Authorize user %s ', sid
		user = @users[sid]
		if not user
			user = 
				sid: sid
				id: sid

			@users[sid] = user

		callback null, user

	userConnected: (socket) ->
		
		user = socket.handshake.user
		@activeUsers[user.id] = user if user
		console.log 'User %s connected', user.id

	userDisconnected: (socket) ->
		user = socket.handshake.user
		delete @activeUsers[user.id] if user
		console.log 'User %s disconnected', user.id

	userJoin: (sessionId, socket, callback) ->
		
		console.log 'User %s joining session %s', socket.handshake.user.id, sessionId
		session = @sessions[sessionId]
		return callback 'no such session' unless session

		session.addUser socket, (err) ->
			return callback 'error adding user' if err
			session.bootstrap(callback)

	createSession: (sessionData, callback) ->
		sessionData.id = g_SessionId++
		console.log 'Create session %j', sessionData
		ns = @skullServer.of '' + sessionData.id
		@sessions[sessionData.id] = new WatchSession(sessionData.id, ns)
		@sessions[sessionData.id].video.video.url = sessionData.url 
		@sessions[sessionData.id].video.video.owner = sessionData.creator
		callback null, sessionData
	
	getSession: (id, callback) ->
		callback 'no such session' unless @sessions[id]

		sess = @sessions[id]

		res = 
			id: sess.id
			video: sess.video.video

		callback null, res
