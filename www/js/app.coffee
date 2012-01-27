
insertIframe = ->
	tag = document.createElement 'script'
	tag.src = 'http://www.youtube.com/player_api'
	
	firstTag = document.getElementsByTagName('script')[0]
	firstTag.parentNode.insertBefore tag, firstTag


extractVideoId = (url) ->
	url.match(/v=(.{11})/)?[1]?.replace(/[^a-z0-9]/ig,'')

WWM.Player = null

class VideoModel extends Skull.Model
	url: '/video'

class UserCollection extends Skull.Collection
	url: '/users'

class VideoView extends Backbone.View
	
	initialize: ->
		@model.bind 'change:url', @changeUrl
		@model.bind 'change:position', @seek
		@model.bind 'change:paused', @pausedChanged
		@changeUrl()

	pausedChanged: =>
		isPaused = @model.get 'paused'
		if isPaused 
			if WWM.Player.getPlayerState() != YT.PlayerState.PAUSED
				WWM.Player.pauseVideo()
		else
			if WWM.Player.getPlayerState() != YT.PlayerState.PLAYING
				WWM.Player.playVideo()
		
	changeUrl: =>
		videoId = extractVideoId @model.get 'url'
		if videoId
			@loadVideo videoId 
			@seek()

	seek: =>
		console.log '-> Seeking to ', @model.get('position')
		WWM.Player.seekTo @model.get('position'), true
		console.log 'Current position: ', WWM.Player.getCurrentTime()

	loadVideo: (videoId) ->
		WWM.Player.loadVideoById videoId

class ViewersView extends Backbone.View
	initialize: ->
		@collection.bind 'change', @updateViewers
		@updateViewers()

	updateViewers: =>
		$(@el).text @collection.length + ' viewers'

connectToServer = ->

	sio = io.connect()
	
	sio.on 'connect', ->
		console.log 'Connected to server'
		
		sio.emit 'join', WWM.session.id, (err, data) ->
			console.log 'Joined session'

			WWM.connected = true

			Skull = require 'skull'

			globalNS = Skull.createClient sio.of(WWM.session.id)
			
			WWM.models = {}
			WWM.models['video'] = globalNS.addModel new VideoModel(data.video)
			WWM.models['users'] = globalNS.addModel new UserCollection(data.users)

			videoView = new VideoView 
				model: WWM.models.video
			
			$('.viewers').text WWM.models['users'].length + ' viewers'

			WWM.models['users'].bind 'all', ->
				$('.viewers').text WWM.models['users'].length + ' viewers'
	
	$('.watch').click ->
		url = $('[name=url]').val()
		videoId = extractVideoId url
		
		WWM.models['video'].save 
			url: url
			position: 0
			paused: false


$ ->

	console.log 'Document ready'
	insertIframe()


saveVideoState = ->
	console.log 'Current getCurrentTime: ', WWM.Player.getCurrentTime()
	url = WWM.Player.getVideoUrl()
	
	WWM.models['video'].save
		paused: WWM.Player.getPlayerState() == YT.PlayerState.PAUSED
		position: Math.round(WWM.Player.getCurrentTime())
		url: url
	, silent: true


insertPlayer = ->
	
	timerId = 0

	$('#player').replaceWith('<div id="player"></div>')

	player = new YT.Player 'player'
		height: 390
		width: 780
		events:
			'onReady': (event) ->
				console.log 'Player ready'
				WWM.Player = event.target
				connectToServer()

			'onStateChange': (e) ->
				console.log 'State changed: ', e.data
				#only allow to broadcast state change from the owner
				return unless WWM.connected
			
				if WWM.models['video'].get('owner') is WWM.user.id
					if e.data == YT.PlayerState.PLAYING
						clearTimeout timerId
						timerId = setTimeout saveVideoState, 150
						console.log 'StateChanged getCurrentTime: ', Math.round(WWM.Player.getCurrentTime())

					if e.data == YT.PlayerState.PAUSED
						clearTimeout timerId
						timerId = setTimeout saveVideoState, 150
						

window.onYouTubePlayerAPIReady = ->
	console.log 'Youtube player API ready!'
	insertPlayer()
	

