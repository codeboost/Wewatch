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
		
		@player.insertPlayer()

		for event in ['playing', 'paused', 'seeked']
			@player.bind event, @delaySaveState
		
	delaySaveState: =>
		_.delay @saveState, 150 if WWM.isModerator
	
	saveState: =>
		return if @changingURL
		@model.save
			paused: @player.isPaused()
			position: @player.getCurrentTime()
			url: @player.getVideoUrl()
		, silent: true

	pausedChanged: =>
		if @model.get 'paused' 
			@player.pauseVideo() unless @player.isPaused()
		else
			@player.playVideo() unless @player.isPlaying()
		
	changeUrl: =>

		videoId = utils.extractVideoId @model.get 'url'
		if videoId
			@changingURL = true
			@player.cueVideoById videoId, @model.get('position')
			@seek()
			if @model.get('paused') 
				@player.pauseVideo()
			@changingURL = false

		
	seek: =>
		@player.seekTo @model.get('position'), true
