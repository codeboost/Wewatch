express = require 'express'
io = require 'socket.io'
WatchSession = require './watchsession'
mongoose = require 'mongoose'



exports.init = (viewsDir) ->
	app = express.createServer()
	app.configure ->
		app.use express.bodyParser()
		app.use express.cookieParser()
		app.use express.static viewsDir 
		app.use express.session {secret: '$#$wt00ne%%', store: new express.session.MemoryStore}
		app.set 'views', viewsDir
		app.set 'view engine', 'jade'
		app.set 'view options', layout: false


	setUser = (req, res, next) ->

		req.session.user ?= 
			id: req.sessionID
		next()

	app.get '/', setUser, (req, res) ->
		console.log req.session
		console.log 'Connect.sid ', req.sessionID

		req.session.user = 
			id: req.sessionID

		res.render 'index'

	app.post '/createSession', setUser, (req, res) ->
		console.log 'Create session: ', req.session

		await g_Server.createSession 
			url: req.body.url
			creator: req.session.user.id
		, defer(err, data) 

		console.log 'Session: ', data
		res.redirect "/w/#{data.id}"

	app.get '/w/:id', setUser, (req, res) ->
		return res.send 500 unless req.session.user

		await g_Server.getSession req.params.id, defer(err, session)

		return res.send 'No such session' if err isnt null
		console.log 'Got session ', session
		console.log 'Rendering session...'
		console.log 'User id ' ,req.session.user.id
		res.render 'w', 	
			session: session
			user: req.session.user

			
				
	return app

app = exports.init('www')
g_Server = new WatchSession.Server app		

conf = require('./config')
console.log conf
port = conf.listen.port
host = conf.listen.host
console.log 'Listening on %s:%d ', host, port 
app.listen port, host