
###
Meta is an application creation framework.

It is basically a script which will generate a HTML5 web application backed by a node.js server. 


Application structure:

server
	index.coffee
	models/
		user.coffee
		session.coffee
		settings.coffee

client
	layout.jade
	index.jade

	css/bootstrap.css
	lib/jquery.js
	lib/underscore.js
	lib/backbone.js
	
	js/
		main.coffee
		config.coffee

	js/widgets
		listview
		carousel

###

app = meta.createApplication()

app.conf
	database:
		type: 'mongodb'
		table_prefix: ''
		name: 'my-project'
	listen:
		interface: '127.0.0.1'
		port: 80

app.include '''
	server
		index.coffee
		
		models/
			user.coffee
			session.coffee
			settings.coffee
		
		views/
			user.coffee
			session.coffee
			settings.coffee
	client
		assets/
			css/bootstrap.css
			images/
			js/lib/jquery.js
			js/lib/underscore.js
			js/lib/backbone.js
			js/lib/module.js
			/socket.io/socket.io.js
			/skull.io/skull.io.js

		views/
			layout.jade
			index.jade

		js/
			models/connection.coffee
			models/user.coffee
			models/
			views/connection.coffee

			main.coffee
			config.coffee

		js/widgets/
			listview
			carousel
'''


