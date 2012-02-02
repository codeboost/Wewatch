window?.module?.enter 'utils'

_.templateSettings = {
  escape : /\{\{(.+?)\}\}/g
	interpolate: /\{\-\{(.+?)\}\}/g
	evaluate: /\{\=\{(.+?)\}\}/g
};

exports.loadTemplate = (name) -> 
	name = if name[0]=='#' then name else '#' + name
	_.template $(name).html()
#FIXME: Find a better solution 
exports.unescapeString = unescapeString = (text) -> $('<div/>').html(text).text()


exports.isYoutubeUrl = (val) ->
	val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/)

exports.extractVideoId = (url) ->
	url.match(/v=(.{11})/)?[1]