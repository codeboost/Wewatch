
Session = require './session'
Skull = require 'skull.io'
_ = require 'underscore'
MSkull = require './mongoose-skull'
mongoose = require 'mongoose'

g_UserId = 4585
g_SessionId  = 1234

class SessionUser extends MSkull.XModel
	constructor: (id_session) ->
		super 'SessionUser', id_session: id_session

class SessionModel extends MSkull.XModel
	constructor: ->
		super 'WatchSession'

class PlaylistItem extends MSkull.XModel
	constructor: (id_session) ->
		super 'PlaylistItem', id_session: id_session

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
			paused: false
			position: 0
			_id: 'v01'
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
	constructor: (@options, @skullServer) ->
		super
		@users = new SessionUser @options._id
		@video = new VideoModel
		@playlist = new PlaylistItem(@options._id)

		@ns = @skullServer.of '' + @options._id
		@ns.addModel '/users', @users
		@ns.addModel '/video', @video
		@ns.addModel '/playlist', @playlist
		console.log 'Created watch session ', @id

		@video.video.owner = @options.creator
		@video.video.url = @options.url

	addUser: (socket, callback) ->
		user = socket.handshake.user

		await @users.create 
			id_user: user._id
			name: user.name
			email: user.email
			id_session: @options._id
			avatar: user.avatar
		, defer(err, newUser), socket

		console.log 'Add user %s to session %s', newUser.id, @id

		socket.on 'disconnect', => 
			console.log 'User disconnected'
			@users.delete newUser, null, socket
		
		callback null

	bootstrap: (callback) ->
		
		await @playlist.read {}, defer(err, playlist) 
		await @users.read {}, defer(err, users)

		ret = 
			playlist: playlist
			users: users
			video: @video.video

		callback null, ret


exports.Server = class WatchSessionManager extends Session.SessionManager
	constructor: ->
		super
		@sessions = {}
		@users = {}
		@activeUsers = {}
		@skullServer = new Skull.Server @io
		@sessionModel = new SessionModel 

		#cannot get mapreduce to work, so i'll do it manually
		await @sessionModel.model.find {}, {docid: 1}, defer(err, docs)

		if err is null
			maxVal = 0
			_.each docs, (doc) ->
				doc = doc.toObject()
				return unless doc.docid
				if doc.docid > maxVal then maxVal = doc.docid
			
			g_SessionId = maxVal ? 1234
			g_SessionId = g_SessionId + 1 
			console.log 'g_SessionId = ', g_SessionId

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
		return callback? 'no such session' unless session

		session.addUser socket, (err) ->
			return callback 'error adding user' if err
			session.bootstrap(callback)

	createSession: (sessionData, callback) ->
		sessionData.docid = g_SessionId++
		console.log 'Create session %j', sessionData

		await @sessionModel.create sessionData, defer(err, sess)

		return callback "error creating session" if err

		@sessions[sess.docid] = new WatchSession(sess, @skullServer)
			
		callback null, sess
	
	getSession: (docid, callback) ->
		#callback 'no such session' unless @sessions[id]

		if not @sessions[docid]
			await @sessionModel.findOne {docid: parseInt(docid)}, defer(err, sess)
			console.log 'Session find: ', err, sess
			return callback err ? "error, no such session" if not sess
			@sessions[sess.docid] = new WatchSession(sess, @skullServer)

		sess = @sessions[docid]

		res = 
			docid: sess.options.docid
			_id: sess.options._id
			video: sess.video.video
			creator: sess.options.creator

		callback null, res
