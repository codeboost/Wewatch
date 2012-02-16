
utils = require 'utils'

$ ->

	urlInput = $('[name=url]')
	$('.you').submit (e) ->
		val = urlInput.val()

		if not utils.isYoutubeUrl(val)
			$('.err-message').removeClass('hidden').text "Not a valid youtube URL"
			e.preventDefault()
			false

		videoId = utils.extractVideoId val

		$.getJSON 'https://gdata.youtube.com/feeds/api/videos/' + videoId + '?v=2&alt=jsonc&callback=?', (resp, textStatus) ->
			if textStatus == 'success'
				item = utils.extractItemAttributes resp.data
				item.url = val

				$.post '/createSession', item, (resp, textStatus) ->
					if resp?.sessionId
						window.location = '/w/' + resp.sessionId
					else
						$('.err-message').removeClass('hidden').text "Error creating session"

		e.preventDefault()
		return false
	

	urlInput.keyup ->
		val = urlInput.val()
		if utils.isYoutubeUrl(val)
			$('.err-message').addClass 'hidden'