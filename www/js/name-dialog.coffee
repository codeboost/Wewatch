window.module?.enter 'name-dialog'

class UserModel extends Backbone.Model

class NameDialog extends Backbone.View
	initialize: ->
		@setElement $('#name-dialog')

		@$('.btn.primary').click (e) =>
			console.log 'Clicked'

			name = $.trim @$('[name=user-name]').val()

			$.post '/setName',  {name: name}, (err, resp) =>
				@model.set name: name
				@callback? (@model.toJSON())
				@$el.modal('hide')


	render: ->
		@

	show: (@callback) ->
		@$el.show().modal
			backdrop: 'static'
			keyboard: false

		@$('input').focus()

g_Dialog = null


exports.show = (callback) ->
	if g_Dialog
		g_Dialog.show(callback)
	else
		g_Dialog = new NameDialog
			model: new UserModel

		g_Dialog.show(callback)