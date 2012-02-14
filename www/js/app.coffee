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
WWM.playbackState = 'playing'


class AppView extends Backbone.View
	initialize: ->

		@el = $('#main-container')
		@playerView = new PlayerView.PlayerView
			model: WWM.models.video

		@playlistView = new Playlist.View 
			collection: WWM.models.playlist
			el: @$('.playlist-view')
		
		@playlistView.collection.bind 'selected', (model) ->
			console.log 'Selected: ', model.toJSON()
			WWM.models.video.save model.toJSON()

		@chatView = new Chat.View
			el: @$('.chat-view')
			collection: WWM.models.chat

		WWM.models.users.bind 'all', @updateViewers

		WWM.models.users.bind 'server-broadcast', (data) ->
			WWM.models.chat.add data
		
		#do not bind to 'add', because it gets triggered when data is received from the server. 
		#new-msg means *current* user typed in something
		WWM.models.chat.bind 'new-msg', (data) ->
			WWM.models.users.broadcast data



		@playlistView.render()
		@updateViewers()
	
	updateViewers: =>
		@$('.viewers').text WWM.models.users.length + ' viewers'

	show: ->
		@el.show()
		@


createYTFrame = ->
	tag = document.createElement 'script'
	tag.src = 'http://www.youtube.com/player_api'
	firstTag = document.getElementsByTagName('script')[0]
	firstTag.parentNode.insertBefore tag, firstTag

window.onYouTubePlayerAPIReady = ->
	console.log 'Youtube player API ready!'
	console.log 'Connecting to server'

	model = new Backbone.Model 
		name: 'Maria'
		age: 16

	model.bind 'change:name', (newv) ->
		console.log 'Name is ' + @get('name') + ' and age is ' + @get('age')

	model.set 
		name: 'John'
		age: 23



	WWM.conn = new ioState.ConnectionState
	WWM.conn.bind 'joined', (bootstrap) ->
			globalNS = Skull.createClient WWM.conn.sio.of(WWM.session._id)
			WWM.models = require('models').init(globalNS, bootstrap)

			if WWM.user.name?.length
				return (new AppView).show()

			NameDialog.show (mdl) ->
				(new AppView).show()
	
	WWM.conn.join WWM.session.docid

exports.start = ->
	$ ->
		createYTFrame()


			


