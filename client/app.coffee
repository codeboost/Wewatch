window?.module?.enter 'app'

ioState = require 'ioState'
Playlist = require 'playlist'
PlayerView = require 'playerView'
NameDialog = require 'name-dialog'
Chat = require 'chat'
Bookmarks = require 'bookmarks'

WWM.Player = null

WWM.isModerator = WWM.session.creator == WWM.user._id

#flag is true when the views have been created
WWM.initialized = false
WWM.paused = false

class RighSide extends Backbone.View
	events: 
		'click .select-bookmarks': 'selectBookmarks'
		'click .select-playlist': 'selectPlaylist'

	initialize: ->
		
		@playlist = new Playlist.View 
			collection: WWM.models.playlist
			el: @$('.playlist-view')
		
		@bookmarks = new Bookmarks.View
			collection: WWM.models.bookmarks
			el: @$('.bookmarks-view')
	
		@tabs = 
			bookmarks: @$('.select-bookmarks')
			playlist: @$('.select-playlist')

		@curView = @playlist

	selectBookmarks: (e) =>
		e?.preventDefault()

		@playlist.$el.hide()
		@bookmarks.$el.show()

		@tabs.bookmarks.addClass 'active'
		@tabs.playlist.removeClass 'active'
		@curView = @bookmarks

	selectPlaylist: (e) =>
		e?.preventDefault()	
		@bookmarks.$el.hide()
		@playlist.$el.show()
		@tabs.bookmarks.removeClass 'active'
		@tabs.playlist.addClass 'active'
		@curView = @playlist

	render: =>
		@curView.render()


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
			@$('.right-side').show()
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
	events:
		'click .mark-in': 'markIn'
		'click .mark-out': 'markOut'

	initialize: ->

		@setElement $('#main-container')
		#connection view: monitor connection and display message on error
		@connectionView = new ConnectionView
			el: $('.connection-view')
			model: WWM.conn

		#shows number of views, number of viewers, etc
		@videoInfo = new VideoInfo 
			el: @el
			model: WWM.models.video
			usersModel: WWM.models.users

		#the youtube player
		@playerView = new PlayerView.PlayerView
			model: WWM.models.video

		#playlist and bookmarks
		@rightSide = new RighSide
			el: @$('.right-side')

		#chat unit
		@chatView = new Chat.View
			el: @$('.chat-view')
			collection: WWM.models.chat

		#mark user as inactive
		$(window).blur ->
			myModel = WWM.models.users.filter (viewer) -> viewer.get('id_user') == WWM.user._id
			myModel?[0]?.save idle: true
			WWM.idle = true

		#mark user as active
		$(window).focus ->
			myModel = WWM.models.users.filter (viewer) -> viewer.get('id_user') == WWM.user._id
			myModel?[0]?.save idle: false
			WWM.idle = false

		@editButtons = 
			markIn: @$('.mark-in')
			markOut: @$('.mark-out')

		@rightSide.render()

		WWM.initialized = true

	markIn: ->
		return unless WWM.isModerator
		@rightSide.selectBookmarks()

		point = WWM.models.video.toJSON()
		delete point._id
		point.position = @playerView.player.getCurrentTime()

		@lastPoint = WWM.models.bookmarks.create point


	markOut: ->
		return unless WWM.isModerator
		return unless @lastPoint

		@rightSide.selectBookmarks()

		startPos = @lastPoint.get 'position'
		curPos = @playerView.player.getCurrentTime()

		len = curPos - startPos
		return unless len > 0

		@lastPoint.save
			length: len

		@lastPoint = null

	show: ->
		@$el.show()
		@

WWM.bindEvents = ->
	#select a playlist item
	WWM.models.playlist.bind 'selected', (model) ->
		return unless WWM.isModerator
		vid = model.toJSON()
		console.log 'Selected: ', vid
		delete vid._id
		WWM.models.video.set vid 

	#chat message arrives from server
	WWM.models.users.bind 'server-broadcast', WWM.models.chat.add
	
	#new chat message entered by user
	#do not bind to 'add', because it gets triggered when data is received from the server. 
	#new-msg means *current* user typed in something
	WWM.models.chat.bind 'new-msg', WWM.models.users.broadcast


	WWM.models.bookmarks.bind 'selected', (model) ->
		return unless WWM.isModerator
		vid = model.toJSON()
		delete vid._id
		WWM.models.video.set vid


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

			#create socket.io namespace
			ns = WWM.conn.sio.of(WWM.session._id)
			#create Skull namespace
			globalNS = Skull.createClient ns

			#create the models and initialize them with current data
			require('models').init(globalNS, bootstrap)

			#bind model events
			WWM.bindEvents()

			#this is set by AppView
			if WWM.initialized 
				return

			#finally, create the app view
			if WWM.user.name?.length 
				return (new AppView).show()

			NameDialog.show (mdl) ->
				WWM.user.name = mdl.name
				(new AppView).show()
	
	WWM.conn.join WWM.session.docid

exports.start = ->
	$ ->
		createYTFrame()


			


