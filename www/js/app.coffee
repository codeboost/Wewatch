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
WWM.paused = false


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
		total = @options.usersModel.length

		fnReduce = (memo, item) ->
			if item.get('idle') then memo else return memo + 1

		active = @options.usersModel.reduce fnReduce, 0

		@viewers.text active + '/' + total + ' viewers'

	update: =>
		

		if WWM.isModerator
			@title.text 'You are presenting'
			@$('.search-view').show()
		else

			ret = @options.usersModel.filter (usr) -> WWM.session.creator == usr.get('id_user')

			presenter = ret?[0]?.get('name') ? 'No one'

			@title.text presenter + ' is presenting'

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
			return unless WWM.isModerator
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

		$(window).blur ->
			myModel = WWM.models.users.filter (viewer) -> viewer.get('id_user') == WWM.user._id
			myModel?[0]?.save idle: true
			WWM.idle = true

		$(window).focus ->
			myModel = WWM.models.users.filter (viewer) -> viewer.get('id_user') == WWM.user._id
			myModel?[0]?.save idle: false
			WWM.idle = false


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

			ns = WWM.conn.sio.of(WWM.session._id)

			ns.emit 'hello world'

			globalNS = Skull.createClient ns
			require('models').init(globalNS, bootstrap)

			if WWM.initialized 
				return
			
			if WWM.user.name?.length 
				return (new AppView).show()

			NameDialog.show (mdl) ->
				WWM.user.name = mdl.name
				(new AppView).show()
	
	WWM.conn.join WWM.session.docid

exports.start = ->
	$ ->
		createYTFrame()


			


