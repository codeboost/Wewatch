stitch = require 'stitch'
fs = require 'fs'
_ = require 'underscore'
conf = require './config'
spawn = require('child_process').spawn

console.log conf

deps = _.map conf.deps, (dep) -> __dirname + '/' + dep
scripts = _.map conf.scripts, (scr) -> __dirname + '/' + scr

console.log 'Deps = ', deps
console.log 'Scripts = ', scripts

pkg = stitch.createPackage
	paths: scripts
	dependencies: deps

await pkg.compile defer(err, source) 

return console.log err if err

await fs.writeFile __dirname + '/' + conf.output, source, defer(err)

return console.log err if err

console.log 'Uglifying...'

ret = spawn 'uglifyjs', ['-o', __dirname + '/' + conf.output_min, 'compiled.js']

ret.on 'exit', (code) ->
	if code == 0
		console.log 'Compiled, all good, congratulations, you are great!'
	else
		console.log 'uglify exited with ', code