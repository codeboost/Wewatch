window.module?.enter 'name-dialog'

class UserModel extends Backbone.Model

class NameDialog extends Backbone.View
	initialize: ->
		@setElement $('#name-dialog')
		@input = @$('[name=user-name]')

		@input.keyup (e) =>
			@submitForm() if e.keyCode == 13

		@$('.btn.primary').click (e) =>
			console.log 'Clicked'


	submitForm: =>

		name = _.escape $.trim @input.val()
		return unless name.length 

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