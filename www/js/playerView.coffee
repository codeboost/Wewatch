window.module?.enter 'playerView'

utils = require 'utils'
yt = require 'yt'

class exports.PlayerView extends Backbone.View
	initialize: ->
		@model.bind 'change:url', @changeUrl
		@model.bind 'change:position', @seek
		@model.bind 'change:paused', @pausedChanged

		@player = new yt.Player 
			controls: true

		@player.state.bind 'ready', =>
			@changeUrl()

		#saveStateTimer
		@st = 0 
		
		@player.insertPlayer()
		
		#player state changes -> save it
		@player.bind 'playing', => 
			console.log '~ Playing'
			@delaySaveState()

		@player.bind 'paused', =>
			console.log '~ Paused'
		 @delaySaveState()

		@player.bind 'seeked', =>
			console.log '~ Seeked'
			@delaySaveState()

	delaySaveState: =>
		clearTimeout(@st)
		@st = _.delay @saveState, 150 if WWM.isModerator
	
	saveState: =>
		return if @changingURL
		
		state = 
			paused: @player.isPaused()
			position: @player.getCurrentTime()
			url: @player.getVideoUrl()

		console.log '*Saving state: ', state

		@model.save state, silent: true

	pausedChanged: =>
		if @model.get 'paused' 
			@player.pauseVideo() unless @player.isPaused()
		else
			@player.playVideo() unless @player.isPlaying()
		
	changeUrl: =>

		console.log 'Change URL: ' + @model.get('url') + ' -> ' + @model.get('position')
		videoId = utils.extractVideoId @model.get 'url'
		if videoId
			@changingURL = true
			@player.cueVideoById videoId, @model.get('position')
			@changingURL = false

	seek: =>
		@player.seekTo @model.get('position'), true
