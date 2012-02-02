window?.module?.enter 'playlist'

utils = require 'utils'

class OnePlayItem extends Backbone.View
	tagName: 'tr'
	className: 'play-item'

	events:
		'click .thumbnail': 'thumbnailClicked'
		'click': 'itemclicked'

	initialize: ->
		@template = utils.loadTemplate 'one-play-item' 		
		@model.bind 'change', @render
		@model.bind 'destroy', => @remove()
	
	thumbnailClicked: (e) =>

		userId = WWM.user._id

		cur = @model.get('voters') ? new Array

		if cur.indexOf(userId) isnt -1 then return false

		cur.push userId

		@model.save
			voters: cur
	
		@model.trigger 'votes-changed', @model
		e.preventDefault()
		false


	itemclicked: ->
		@model.trigger 'selected', @model

	render: =>
		$(@el).html @template @model.toJSON()		
		@

class exports.View extends Backbone.View

	initialize: ->
		@el = $ $(@domEl).html() if @domEl
		@collection.bind 'add', @addOne
		@collection.bind 'reset', @addAll
		@collection.bind 'votes-changed', => @collection.sort()
		@items = @el

	addOne: (item) =>
		view = new OnePlayItem model: item
		@items.append view.render().el

	addAll: =>
		@items.empty()
		@collection.each @addOne

	render: =>
		@addAll()
		@
		