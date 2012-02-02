express = require 'express'
io = require 'socket.io'
WatchSession = require './watchsession'
mongoose = require 'mongoose'
conf = require('./config')
require('./models')

mongoose.connect conf.db.path

mongoose.connection.on 'error', (err) ->
	console.log 'FATAL: Database connection error. Please check if mongodb is running or edit configuration in conf.coffee'
	process.exit -1

SessionStore = require('./sessionStore').SessionStore
sessionStore = new SessionStore()

Models = 
	User: mongoose.model 'User'


exports.init = (viewsDir) ->
	app = express.createServer()
	app.configure ->
		app.use express.bodyParser()
		app.use express.cookieParser()
		app.use express.static viewsDir 
		app.use express.session {secret: '$#$wt00ne%%', store: sessionStore}
		app.set 'views', viewsDir
		app.set 'view engine', 'jade'
		app.set 'view options', layout: false

		app.dynamicHelpers
			isProduction: (req, res) -> conf.server.production


	setUser = (req, res, next) ->
		if not req.session.user
			console.log 'Looking up user'
			#lookup from database
			await Models.User.findOne {sid: req.sessionID}, defer(err, user)
			
			console.log 'Looked up user: %d', err

			if not user
				console.log 'Creating blank user'
				await Models.User.create {sid: req.sessionID}, defer(err, user)
			else
				console.log 'User found. UserId = ', user._id

			req.session.user = user.toObject()

			next()
		else
			next()

	app.get '/', setUser, (req, res) ->
		res.render 'index'

	app.post '/createSession', setUser, (req, res) ->
		await g_Server.createSession 
			url: req.body.url
			creator: req.session.user._id
		, defer(err, data) 

		res.redirect "/w/#{data.docid}"

	app.get '/w/:id', setUser, (req, res) ->
		return res.send 500 unless req.session.user

		console.log 'Getting session ', req.params.id
		await g_Server.getSession req.params.id, defer(err, session)
		
		return res.send 'No such session' if err isnt null
		console.log 'Rendering session...', session
		res.render 'w', 	
			session: session
			user: req.session.user

			
				
	return app

app = exports.init('www')
g_Server = new WatchSession.Server app		


console.log conf
port = conf.listen.port
host = conf.listen.host
console.log 'Listening on %s:%d ', host, port 
app.listen port, host