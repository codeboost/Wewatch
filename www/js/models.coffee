window?.module?.enter 'models'

Backbone.Model::idAttribute = '_id'


class OneChatLine extends Backbone.Model

class ChatLinesCollection extends Backbone.Collection
	model: OneChatLine


class VideoModel extends Skull.Model
	url: '/video'

class UserCollection extends Skull.Collection
	url: '/users'


class PlayItem extends Skull.Model
	defaults:
		url: ''
		thumbnail: ''
		position: 0
		uploader: 'dj sample'
		viewCount: 345
		paused: false
		votes: 0
		voters: null

		
class Playlist extends Skull.Collection
	model: PlayItem
	url: '/playlist'
	
	comparator: (item) ->
		votes = item.get('voters')?.length ? 0
		-votes

exports.init = (ns, bootstrap) ->

	models = WWM.models ?= {}

	(models.video ?= ns.addModel new VideoModel).set bootstrap.video
	(models.users ?= ns.addModel new UserCollection).reset bootstrap.users
	(models.playlist ?= ns.addModel new Playlist).reset bootstrap.playlist
	(models.chat ?= new ChatLinesCollection)

	models