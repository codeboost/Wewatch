window.module?.enter 'yt'

exports.PlayerState = class PlayerState extends Backbone.Model
	defaults:
		ready: false
		state: 0
		error: ''

class exports.Player extends Backbone.View
	initialize: ->
		@state = new PlayerState
		@idPlayer = @options.idPlayer ? 'player'
		@state.bind 'change:ready', @marshall

	marshall: =>

		@[fn] = _.bind(@player[fn], @player) for fn in '''
		cueVideoById
		loadVideoById
		seekTo
		playVideo
		pauseVideo
		getPlayerState
		getVideoUrl
		'''.split('\n')

	isPaused: =>
		@player.getPlayerState() == YT.PlayerState.PAUSED

	isPlaying: =>
		@player.getPlayerState() == YT.PlayerState.PLAYING

	getCurrentTime: ->
		Math.round(@player.getCurrentTime())

	insertPlayer: ->
		playerState = @state
		@player = new YT.Player @idPlayer,
			height: @options.height ? 390
			width: @options.width ? '100%'
			playerVars: { 'autoplay': 0, 'controls': if @options.controls then '1' else '0'}
			events:
				onReady: ->
					playerState.set ready: true
					playerState.trigger 'ready'

				onStateChange: (event) =>

					prevState = playerState.get 'state'

					playerState.set state: event.data
						
					switch event.data
						when YT.PlayerState.PLAYING
							if prevState == YT.PlayerState.PLAYING then @trigger 'seeked' else @trigger 'playing'
						when YT.PlayerState.PAUSED
							if prevState == YT.PlayerState.PAUSED then @trigger 'seeked' else @trigger 'playing'

				onError: (err) ->
					playerState.set error: switch err
						when 2 then 'Invalid parameters'
						when 100 then 'Video not found'
						when 101 or 150 then 'Video cannot be embedded'
						else 'Unknown error'
					 
	