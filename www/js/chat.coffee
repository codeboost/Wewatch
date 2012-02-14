window.module?.enter 'chat'

utils = require 'utils'
class OneChatView extends Backbone.View
	
	tagName: 'li'

	initialize: ->
		@template =  utils.loadTemplate 'one-chat-item'
		@model.bind 'change', @render

	render: =>
		$(@el).html @template @model.toJSON()
		@

class Messages extends Backbone.View

	initialize: ->
		@collection.bind 'add', @addOne
		@collection.bind 'reset', @addAll

	addOne: (item) =>
		view = new OneChatView model: item
		@el.prepend view.render().el

	addAll: (items) ->
		@el.empty()
		@collection.each @addOne

	render: ->
		@addAll()
		@

exports.View = class ChatView extends Backbone.View
	events:
		'keyup input.chat-message': 'onChatKeyUp'

	initialize: ->
		
		@messages = new Messages 
			el: @$('.messages')
			collection: @collection
		
		@chatInput = @$('[name=chat-message]')

		@messages.render()

	onChatKeyUp: (e) =>
		if e.keyCode == 13
			txt = $.trim @chatInput.val()
			return unless txt.length
				 
			data = 
				from: WWM.user.name
				message: _.escape txt

			@collection.add data
			@collection.trigger 'new-msg', data
			@chatInput.val('')
