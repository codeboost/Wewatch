module.exports = 
	www_dir: '../www'
	output: '../www/compiled.js'
	output_min: '../www/compiled.min.js'
	keep_output: false
	deps:[
		'vendor/jquery-1.7.1.min.js'
		'vendor/underscore.js'
		'vendor/backbone-0.9.1.js'
		'vendor/socket.io-0.8.7.js'
		'vendor/skull-client.js'
		'vendor/console-dummy.js'
	]
	scripts: ['js']