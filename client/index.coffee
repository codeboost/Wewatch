window?.module?.enter 'index'
utils = require 'utils'


showError = (msg) ->
	r = $('.err-message')
	$('.alert', r).text msg

	r.removeClass 'hidden'

hideError: ->
	$('.err-message').addClass 'hidden'

exports.start = ->
	$ ->

		urlInput = $('[name=url]')
		$('.you').submit (e) ->
			val = urlInput.val()

			if not utils.isYoutubeUrl(val)
				showError "Not a valid youtube URL"
				e.preventDefault()
				false

			videoId = utils.extractVideoId val

			$.getJSON 'https://gdata.youtube.com/feeds/api/videos/' + videoId + '?v=2&alt=jsonc&callback=?', (resp, textStatus) ->
				if textStatus == 'success' && not resp.error
					item = utils.extractItemAttributes resp.data
					item.url = val

					$.post '/createSession', item, (resp, textStatus) ->
						if resp?.sessionId
							window.location = '/w/' + resp.sessionId
						else
							showError 'Error fetching video details: ', resp.error

			e.preventDefault()
			return false
		

		urlInput.keyup ->
			val = urlInput.val()
			if utils.isYoutubeUrl(val)
				$('.err-message').addClass 'hidden'