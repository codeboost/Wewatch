
$ ->

	urlInput = $('[name=url]')
	$('.you').submit (e) ->
		val = urlInput.val()

		if not val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/)
			$('.err-message').removeClass 'hidden'
			e.preventDefault()
			false

	urlInput.keyup ->
		val = urlInput.val()
		if val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/)
			$('.err-message').addClass 'hidden'