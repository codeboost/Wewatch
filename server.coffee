express = require 'express'
io = require 'socket.io'
WSMng = require './wsmng'
mongoose = require 'mongoose'
conf = require('./config')
require('./models')
_ = require 'underscore'
MSkull = require './mongoose-skull'

mongoose.connect conf.db.path

mongoose.connection.on 'error', (err) ->
	console.log 'FATAL: Database connection error. Please check if mongodb is running or edit configuration in conf.coffee'
	process.exit -1

SessionStore = require('./sessionStore').SessionStore
sessionStore = new SessionStore()

#Models = 
#	User: mongoose.model 'User'

class UserModel extends MSkull.Model
	model: 'User'

g_User = new UserModel


exports.init = (viewsDir) ->
	app = express.createServer()
	app.configure ->
		app.use express.bodyParser()
		app.use express.cookieParser()
		app.use express.static viewsDir 
		app.use express.session 
			secret: '$#$wt00ne%%' 
			store: sessionStore 
			cookie: {maxAge: 24 * 3600 * 30 * 1000}

		app.set 'views', viewsDir
		app.set 'view engine', 'jade'
		app.set 'view options', layout: false

		app.dynamicHelpers
			isProduction: (req, res) -> conf.server.production


	setUser = (req, res, next) ->
		if not req.session.user
			console.log 'Looking up user'
			#lookup from database
			await g_User.findOne {sid: req.sessionID}, defer(err, user)
			
			console.log 'Looked up user: %d', err

			if not user
				console.log 'Creating blank user'
				await g_User.create {sid: req.sessionID}, defer(err, user)
			else
				console.log 'User found. UserId = ', user._id

			req.session.user = user

			next()
		else
			next()

	app.get '/', setUser, (req, res) ->
		res.render 'index'

	app.post '/createSession', setUser, (req, res) ->
		params = req.body
		params.creator = req.session.user._id

		console.log 'Create session params: ', params
		
		return unless params.url and params.title

		await g_Server.createSession params, defer(err, sess) 

		await sess.data defer(err, data)

		console.log 'Session data: ', data
		req.session.user.sessionId = data.docid
		
		await req.session.save defer(err) 

		#res.redirect "/w/#{data.docid}"
		res.send sessionId: data.docid

	app.get '/w/:id', setUser, (req, res) ->
		return res.send 500 unless req.session.user

		console.log 'Getting session ', req.params.id
		await g_Server.getSession req.params.id, defer(err, session)
		
		return res.send 'No such session' if err isnt null or session is null
		
		await session.data defer(err, data)

		console.log 'Rendering session...', data
		res.render 'w', 	
			session: data
			user: req.session.user
			isModerator: data.creator == req.session.user._id


	app.post '/setName', setUser, (req, res) ->
		name = req.body.name
		return res.send 500 unless name?.length

		name = _.escape name
		req.session.user.name = name

		await g_User.update req.session.user, defer(err, user) 

		#update session members
		g_Server.updateMemberDetails req.session.user.sessionId, req.session.user
		req.session.save()
		res.send {status: 'success'}

		console.log req.session.user

	app.get '/about', setUser, (req, res) ->
		res.render 'about'

	app.get '/help', setUser, (req, res) ->
		res.render 'help'

			
				
	return app

app = exports.init('www')
g_Server = new WSMng.Server app		


console.log conf
port = conf.listen.port
host = conf.listen.host
console.log 'Listening on %s:%d ', host, port 
app.listen port, host