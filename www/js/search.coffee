window?.module?.enter 'search'
utils = require 'utils'

class OneSearchItem extends Backbone.Model

class SearchResultsCollection extends Backbone.Collection
	model: OneSearchItem


class OneSearchItemView extends Backbone.View
	tagName: 'tr'
	className: 'search-item'

	initialize: ->
		@template =  utils.loadTemplate 'one-search-item'
		@model.bind 'change', @render

	render: =>
		$(@el).html @template @model.toJSON()
		$(@el).attr 'id_model', @model.get 'videoId'
		@


exports.View = class SearchView extends Backbone.View
	OneItemView: OneSearchItemView
	events: 
		'keyup input': 'oninputkeyup'
		'mouseover tr': 'onmouseover'
		'mouseout tr': 'onmouseout'
		'click tr': 'onclickselected'
		'keyup': 'onkeyup'

	initialize: ->
		@el = $ $(@domEl).html() if @domEl

		@collection = new SearchResultsCollection
		@collection.bind 'add', @addOne
		@collection.bind 'reset', @addAll
		@searchResults = @$('.search-place')
		@items = $('.search-results', @searchResults)
		@input = @$('.search-video')
		@searchTimer = 0
		$(document).bind 'click', (e) =>
			return if $(e.target).is('input.search-video') #don't hide if we click in the search input
			@searchResults.hide()

		@input.focus (e) =>
			@showSearchResults()
	
		
	onmouseover: (e) ->
		$(e.currentTarget).addClass 'selected'
	
	onmouseout: (e) ->
		$(e.currentTarget).removeClass 'selected'
	
	onkeyup: (e) =>
		if e.keyCode == 27
			@searchResults.hide()
			false
		
		if e.keyCode == 13
			@onclickselected()
			false
	
	onclickselected: =>
		console.log 'Click selected!'
		id = @getSelected().attr('id_model')

		model = @collection.find (item) -> item.get('videoId') == id

		@trigger 'selected', model
		@searchResults.hide()
	

	getSelected: ->
		cur = @$('.selected')

		if cur.length == 0
			cur = @$('li:first')
		
		return cur

	selectNext: ->
		return unless cur = @getSelected()
		next = cur.next()
		if next.length is 0 then next = @$('li:first')
		cur.removeClass('selected')
		next.addClass 'selected'

	selectPrev: ->
		return unless cur = @getSelected()
		prev = cur.prev()
		if prev.length is 0 then prev = @$('li:last')
		cur.removeClass('selected')
		prev.addClass 'selected'
		
	oninputkeyup: (e) =>
		
		if e.keyCode == 38
			@selectPrev()
			e.preventDefault()
			e.stopPropagation()
			return false
		
		if e.keyCode == 40
			@selectNext()
			e.preventDefault()
			e.stopPropagation()
			return false
			

		txt = $.trim @input.val()

		if txt.length > 3 
			if txt != @lastText
				@lastText = txt
				clearTimeout @searchTimer
				@searchTimer = setTimeout @performSearch, 250
			else
				@showSearchResults()
		else
			@searchResults.hide()

	extractAttributes: (item) ->
		ret = 
			thumbnail: item.thumbnail.sqDefault
			title: item.title
			viewCount: item.viewCount
			uploader: item.uploader
			url: item.url
			videoId: item.id
		return ret
		

	showSearchResults: =>
		return unless @collection.length 
		@searchResults.show()
		top = @searchResults.offset().top
		docHeight = $(window).innerHeight()
		srHeight = Math.min(@items.height(), docHeight - top - 10)
		#srHeight = docHeight - top - 10
		@searchResults.height srHeight
		

	performSearch: =>
		txt = $.trim @input.val()
		return unless txt.length 

		@collection.reset()

		if utils.isYoutubeUrl txt
			videoId = utils.extractVideoId txt
			$.getJSON 'https://gdata.youtube.com/feeds/api/videos/' + videoId + '?v=2&alt=jsonc&callback=?', (resp, textStatus) =>
				if textStatus == 'success'
						@collection.reset [@extractAttributes(resp.data)]
						@showSearchResults()
					else
						console.log 'Cannot get video info'
						@searchResults.hide() #Better display 'nothing found'
		else
			$.getJSON 'https://gdata.youtube.com/feeds/api/videos?q=' + txt + '&v=2&alt=jsonc&callback=?', (resp, textStatus) =>
				if textStatus == 'success' and resp?.data?.totalItems
					items = (@extractAttributes(item) for item in resp.data.items)
					@collection.reset items
					@showSearchResults()
				else
					console.log 'Nothing found'
					@searchResults.hide()		

	addOne: (item) =>
		view = new @OneItemView model: item
		@items.append view.render().el

	addAll: =>
		@items.empty()
		@collection.each @addOne
	
	render: ->
		@


exports.createView = (el) ->
	
	new SearchView 
		el: el
		




		