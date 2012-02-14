
Session = require './session'
Skull = require 'skull.io'
_ = require 'underscore'
MSkull = require './mongoose-skull'
mongoose = require 'mongoose'

g_UserId = 4585

class PlaylistItem extends MSkull.XModel
	constructor: (id_session) ->
		super 'PlaylistItem', id_session: id_session

class UserModel extends Skull.Model
	constructor: ->
		@users = {}	
		@idUser = 9944

	next_id: ->
		@idUser++

	findByUid: (uid, callback) ->
		for key, user of @users
			if user.id_user == uid 
				return callback null, user

		callback null
		

	read: (filter, callback) ->
		callback null, _.toArray @users

	create: (data, callback, socket) ->
		@users[data._id] = data
		callback? null, data
		@emit 'create', data, socket

	update: (data, callback, socket) ->
		@users[data._id] = data
		callback? null, data
		@emit 'update', data, socket

	delete: (data, callback, socket) ->
		delete @users[data._id]
		callback? null, data
		@emit 'delete', data, socket

	broadcast: (data, callback, socket) ->
		data.message = _.escape data.message
		callback? null
		@emit 'broadcast', data, socket

	
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



exports.Model = class SessionModel extends MSkull.XModel
	constructor: ->
		super 'WatchSession'
				
exports.One = class WatchSession extends Session.Session
	constructor: (@options, @skullServer) ->
		super
		@users = new UserModel
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

		console.log 'Add User: ', user

		await @users.create 
			id_user: user._id
			_id: @users.next_id()
			name: user.name
			email: user.email
			id_session: @options._id
			avatar: user.avatar
		, defer(err, newUser), socket

		console.log 'Add user %s to session %s', newUser._id, @id

		socket.on 'disconnect', => 
			console.log 'User disconnected'
			@users.delete newUser, null, socket
		
		callback null

	updateMemberDetails: (user, callback) ->
		console.log 'Updating member details: ', user

		await @users.findByUid user._id, defer(err, member)

		if not member 
			return callback? "not found: " + err 
		
		member.name = user.name
		member.email = user.email
		member.avatar = user.avatar

		await @users.update member, defer(err, member) 

		callback? err, member


	bootstrap: (callback) ->
		
		await @playlist.read {}, defer(err, playlist) 
		await @users.read {}, defer(err, users)

		ret = 
			playlist: playlist
			users: users
			video: @video.video

		callback null, ret

	data: ->
		res = 
			docid: @options.docid
			_id: @options._id
			video: @video.video
			creator: @options.creator
		res







