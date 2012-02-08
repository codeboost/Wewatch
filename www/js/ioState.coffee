window.module?.enter 'ioState'

class exports.ConnectionState extends Backbone.Model
	
	setState: (state, msg) ->
		@set 
			state: state
			message: msg
	
	join: (sessionId) ->
		@setState 'connecting'

		@sio = io.connect()

		@sio.socket.on 'error', (reason) =>
			@setState 'error', reason
			
		@sio.on 'connect', =>
			@setState 'loading'

			@sio.emit 'join', sessionId, (err, bootstrap) =>
				return @setState 'error', err if err 
				@setState 'connected'
				@trigger 'joined', bootstrap

		@sio.on 'disconnect', =>
			@set state: 'disconnected'
			
