stitch = require 'stitch'
fs = require 'fs'
_ = require 'underscore'
conf = require './config'
spawn = require('child_process').spawn

console.log conf

dir = conf.www_dir || __dirname

deps = _.map conf.deps, (dep) -> dir + '/' + dep
scripts = _.map conf.scripts, (scr) -> dir + '/' + scr

console.log 'Deps = ', deps
console.log 'Scripts = ', scripts

pkg = stitch.createPackage
	paths: scripts
	dependencies: deps

await pkg.compile defer(err, source) 

return console.log err if err

await fs.writeFile conf.output, source, defer(err)

return console.log err if err

console.log 'Uglifying...'

source = conf.output #compiled.js

ret = spawn 'uglifyjs', ['-o',  conf.output_min, source]

ret.on 'exit', (code) ->
	if code == 0
		
		if not conf.keep_output
			console.log 'Removing output file: ', conf.output
			await fs.unlink conf.output, defer(err)
			if err == null then console.log 'Ok, removed' else console.log 'Not removed: ', err

		console.log 'Compiled, all good, congratulations, you are great!'
	else
		console.log 'uglify exited with ', code