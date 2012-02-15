window?.module?.enter 'app'

ioState = require 'ioState'
Playlist = require 'playlist'
PlayerView = require 'playerView'
NameDialog = require 'name-dialog'
Chat = require 'chat'


try
	Skull = require 'skull-client'
catch e
	Skull = require 'skull'

WWM.Player = null

WWM.isModerator = WWM.session.creator == WWM.user._id

#flag is true when the views have been created
WWM.initialized = false


class VideoInfo extends Backbone.View

	initialize: ->
		@title = @$('.video-title')
		@viewers = @$('.viewers')
		@totalViews = @$('.total-views')
		@model.bind 'change', @update

		@options.usersModel.bind 'all', @updateViewers

		@update()
		@updateViewers()

	updateViewers: =>
		@viewers.text @options.usersModel.length + ' viewers'

	update: =>
		#@title.text @model.get 'title'

		viewCount = @model.get('viewCount')
		viewCount = if viewCount then viewCount + ' views' else '0'
		@totalViews.text viewCount

class ConnectionView extends Backbone.View
	initialize: ->
		@model.bind 'change', @update

	update: =>
		state = @model.get 'state'
		if state is 'disconnected'
			@$el.show()
		else
			@$el.hide()

class AppView extends Backbone.View
	initialize: ->

		@setElement $('#main-container')

		@connectionView = new ConnectionView
			el: $('.connection-view')
			model: WWM.conn

		@videoInfo = new VideoInfo 
			el: @el
			model: WWM.models.video
			usersModel: WWM.models.users


		@playerView = new PlayerView.PlayerView
			model: WWM.models.video

		@playlistView = new Playlist.View 
			collection: WWM.models.playlist
			el: @$('.playlist-view')
		
		@playlistView.collection.bind 'selected', (model) ->
			vid = model.toJSON()
			console.log 'Selected: ', vid
			delete vid._id
			WWM.models.video.set vid

		@chatView = new Chat.View
			el: @$('.chat-view')
			collection: WWM.models.chat

		WWM.models.users.bind 'server-broadcast', (data) ->
			WWM.models.chat.add data
		
		#do not bind to 'add', because it gets triggered when data is received from the server. 
		#new-msg means *current* user typed in something
		WWM.models.chat.bind 'new-msg', (data) ->
			WWM.models.users.broadcast data

		@playlistView.render()

		WWM.initialized = true
	show: ->
		@$el.show()
		@


createYTFrame = ->
	tag = document.createElement 'script'
	tag.src = 'http://www.youtube.com/player_api'
	firstTag = document.getElementsByTagName('script')[0]
	firstTag.parentNode.insertBefore tag, firstTag

updateModels = (bootstrap) ->
	WWM.models.video.set bootstrap.video
	WWM.models.users.reset bootstrap.users
	WWM.models.playlist.reset bootstrap.playlist

window.onYouTubePlayerAPIReady = ->
	WWM.conn = new ioState.ConnectionState
	WWM.conn.bind 'joined', (bootstrap) ->

			globalNS = Skull.createClient WWM.conn.sio.of(WWM.session._id)
			require('models').init(globalNS, bootstrap)

			if WWM.initialized 
				return
			
			if WWM.user.name?.length 
				return (new AppView).show()

			NameDialog.show (mdl) ->
				(new AppView).show()
	
	WWM.conn.join WWM.session.docid

exports.start = ->
	$ ->
		createYTFrame()


			


