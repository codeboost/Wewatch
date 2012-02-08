window?.module?.enter 'app'

ioState = require 'ioState'
Playlist = require 'playlist'
PlayerView = require 'playerView'

try
	Skull = require 'skull-client'
catch e
	Skull = require 'skull'

WWM.Player = null
WWM.isModerator = WWM.session.creator == WWM.user._id


class AppView extends Backbone.View
	initialize: ->

		@el = $('#main-container')
		@playerView = new PlayerView.PlayerView
			model: WWM.models.video

		@playlistView = new Playlist.View 
			collection: WWM.models.playlist
			el: @$('.playlist-view')
		
		@playlistView.collection.bind 'selected', (model) ->
			WWM.models.video.save model.toJSON()

		WWM.models.users.bind 'all', @updateViewers

		WWM.models.users.bind 'server-broadcast', (data) ->
			console.log 'Server broadcast: ', data

		@chatInput = @$('[name=chat-message]')

		@chatInput.keyup (e) =>
			txt = $.trim @chatInput.val()
			if e.keyCode == 13 and txt.length 
				WWM.models.users.broadcast 
					from: WWM.user._id
					message: txt

		@playlistView.render()
		@updateViewers()
	
	updateViewers: =>
		@$('.viewers').text WWM.models.users.length + ' viewers'




createYTFrame = ->
	tag = document.createElement 'script'
	tag.src = 'http://www.youtube.com/player_api'
	firstTag = document.getElementsByTagName('script')[0]
	firstTag.parentNode.insertBefore tag, firstTag

window.onYouTubePlayerAPIReady = ->
	console.log 'Youtube player API ready!'
	console.log 'Connecting to server'

	WWM.conn = new ioState.ConnectionState
	WWM.conn.bind 'joined', (bootstrap) ->
			globalNS = Skull.createClient WWM.conn.sio.of(WWM.session._id)
			WWM.models = require('models').init(globalNS, bootstrap)
			new AppView

	WWM.conn.join WWM.session.docid

exports.start = ->
	$ ->
		createYTFrame()


			


