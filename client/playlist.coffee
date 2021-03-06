window?.module?.enter 'playlist'

utils = require 'utils'
Search = require 'search'

class OnePlayItem extends Backbone.View
	tagName: 'tr'
	className: 'play-item'

	events:
		'click .thumbnail': 'thumbnailClicked'
		'click': 'itemClicked'
		'click .remove': 'removeItem'

	initialize: ->
		@template = utils.loadTemplate 'one-play-item' 		
		@model.bind 'change', @render
		@model.bind 'remove', => @remove()
	
	removeItem: (e) =>
		e.preventDefault()
		@model.destroy()
		return false
	
	thumbnailClicked: (e) =>

		e.preventDefault()
		return false
		#This functionality is disabled for the time being.
		userId = WWM.user._id
		cur = @model.get('voters')?.slice() ? new Array
		if cur.indexOf(userId) isnt -1 then return false

		#make a copy of the array. We are currently holding a reference to the model's array
		#and Backbone won't fire 'change:voters'.
		cur.push userId
		@model.save {voters: cur}
		@model.trigger 'votes-changed', @model

		false


	itemClicked: ->
		@model.trigger 'selected', @model

	render: =>
		$(@el).html @template @model.toJSON()		
		@

class PlaylistView extends Backbone.View

	initialize: ->
		@collection.bind 'add', @addOne
		@collection.bind 'reset', @addAll
		@collection.bind 'change:voters', @collection.sort

	addOne: (item) =>
		view = new OnePlayItem model: item
		@$el.append view.render().el

	addAll: =>
		@$el.empty()
		@collection.each @addOne

	render: =>
		@addAll()
		@
		
class exports.View extends Backbone.View
	
	initialize: ->
		@thumbnails = new PlaylistView
			el: @$('.playlist')
			collection: @collection

		@search = new Search.View
			el: @$('.search-view')

		@search.bind 'selected', (model) =>
			@collection.create 
				thumbnail: model.get 'thumbnail'
				title: model.get 'title'
				url: 'http://www.youtube.com/watch?v=' + model.get 'videoId'
				uploader: model.get 'uploader'
				viewCount: model.get 'viewCount'
				position: 0
				paused: false

	render: =>
		@thumbnails.render()
		@
