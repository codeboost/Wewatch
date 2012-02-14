Session = require './session'
Skull = require 'skull.io'
_ = require 'underscore'
MSkull = require './mongoose-skull'
mongoose = require 'mongoose'
WatchSession = require './watchsession'

g_SessionId  = 1234

class UserModel extends MSkull.Model
	model: 'User'

exports.Server = class WatchSessionManager extends Session.SessionManager
	constructor: ->
		super
		@sessions = {}
		console.log 'Creating users'
		@User = new UserModel
		@activeUsers = {}
		@skullServer = new Skull.Server @io
		@sessionModel = new WatchSession.Model 

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
		await @User.findOne {sid: sid}, defer(err, user) 

		console.log 'Found user: ', user

		callback err, user

	userConnected: (socket) ->
		user = socket.handshake.user
		@activeUsers[user._id] = user if user
		console.log 'User %s connected', user._id

	userDisconnected: (socket) ->
		user = socket.handshake.user
		delete @activeUsers[user._id] if user
		console.log 'User %s disconnected', user._id

	userJoin: (sessionId, socket, callback) ->
		
		console.log 'User %s joining session %s', socket.handshake.user._id, sessionId
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

		@sessions[sess.docid] = new WatchSession.One(sess, @skullServer)
			
		callback null, sess
	
	getSession: (docid, callback) ->
		#callback 'no such session' unless @sessions[id]

		if not @sessions[docid]
			await @sessionModel.findOne {docid: parseInt(docid)}, defer(err, sess)
			console.log 'Session find: ', err, sess
			return callback err ? "error, no such session" if not sess
			@sessions[sess.docid] = new WatchSession.One(sess, @skullServer)

		sess = @sessions[docid]

		res = 
			docid: sess.options.docid
			_id: sess.options._id
			video: sess.video.video
			creator: sess.options.creator

		callback null, res

	#update member details in the user's session
	updateMemberDetails: (sessionId, user, callback) ->
		sess = @sessions[sessionId]
		return callback? "no such session" unless sess
		sess.updateMemberDetails user, callback
		