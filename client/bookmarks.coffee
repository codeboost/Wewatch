window?.module?.enter 'bookmarks'

utils = require 'utils'

secondsToTime = (secs) ->
	hours = Math.floor(secs / 3600)
	dvm = secs % 3600
	mins = Math.floor(dvm / 60)
	dvs = dvm % 60
	secs = Math.ceil(dvs)

	ret = 
		h: hours
		m: mins
		s: secs



class OneBookmarkItem extends Backbone.View
	tagName: 'tr'
	className: 'play-item'
	events:
		'click': 'itemClicked'
		'click .remove': 'removeItem'

	initialize: ->
		@template = utils.loadTemplate 'one-bookmark-item' 		
		@model.bind 'change', @render
		@model.bind 'remove', => @remove()
	
	removeItem: (e) =>
		e.preventDefault()
		@model.destroy()
		return false
	
	itemClicked: ->
		@model.trigger 'selected', @model

	modelData: ->
		vid = @model.toJSON()
		
		st = secondsToTime vid.position
		sto = []
		sto.push st.h if st.h > 0
		sto.push st.m
		sto.push st.s

		vid.startTime = sto.join(':')
		return vid

	render: =>
		$(@el).html @template @modelData()		
		@


class ManyBookmarks extends Backbone.View
	initialize: ->
		@collection.bind 'add', @addOne
		@collection.bind 'reset', @addAll

	addOne: (item) =>
		view = new OneBookmarkItem model: item
		@$el.append view.render().el

	addAll: =>
		@$el.empty()
		@collection.each @addOne

	render: =>
		@addAll()
		@

exports.View = class View extends Backbone.View
	initialize: =>
		@bookmarks = new ManyBookmarks
			collection: @collection
			el: @$('.bookmarks')

		@bookmarks.addAll()
