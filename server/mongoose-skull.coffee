_ = require 'underscore'
mongoose = require 'mongoose'
EventEmitter = require('events').EventEmitter
Skull = require 'skull.io'


toObject = (item) ->
	
	return item unless item.toObject

	json = item.toObject()

	for key, val of json
		if _.isArray val
			json[key] = _.map val, (element) -> toObject element
		else
			if val and val.toHexString then json[key] = val.toHexString()
	return json


exports.jsonify = jsonify = (item) ->
	return item unless item
	if _.isArray item
		_.map item, (element) -> toObject element
	else
		toObject(item)
	

exports.DbModel = class DbModel extends Skull.Model
	jsonify: jsonify
	
exports.Model = exports.XModel = class XModel extends DbModel
	constructor: (@name, @filter) ->
		name = @name ? @model
		@model = mongoose.model name
		console.log 'Fitler = %j', @filter
		super
		
	read: (filter, callback, extra) ->
		filter = @formatFilter filter
		console.log '%s: Filter used: %j', @name, filter
		@model.find filter, (err, data) =>
			return callback? err if err
			callback? null, @jsonify data
		
	create: (data, callback, extra) ->
		data = _.extend data, @filter
		@model.create data, (err, fresh) =>
			return callback? err if err
			json = @jsonify(fresh)
			console.log 'Created %j', json
			callback? null, json
			@emit 'create', json, extra
	
	update: (data, callback, extra) ->
		#update should not touch our data
		data = _.extend data, @filter
		
		console.log 'Updating to data: %j', data
		
		id = data._id
		delete data._id
		
		@model.update {_id: id}, data, (err) =>
			return callback? err if err
			data._id = id
			callback? null, data
			@emit 'update', data, extra
	
	delete: (itemObj, callback, extra) ->

		item = _id: itemObj._id
		item = _.extend item, @filter
		
		console.log 'Delete filter = %j', item
		@model.remove item, (err) =>
			return callback? err if err
			callback? null, itemObj
			@emit 'delete', itemObj, extra
	
	formatFilter: (filter) ->
		filter ?= {}
		#socket.io sends an empty [] filter. ignore it.
		filter = {} if _.isArray filter
		filter = _.extend filter, @filter
	
	findOne: (filter, callback, extra) ->
		filter = @formatFilter filter
		@model.findOne filter, (err, data) =>
			return callback? err if err
			callback? null, @jsonify data
		
