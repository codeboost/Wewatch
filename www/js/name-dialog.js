(function() {
  var NameDialog, UserModel, g_Dialog, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if ((_ref = window.module) != null) _ref.enter('name-dialog');

  UserModel = (function(_super) {

    __extends(UserModel, _super);

    function UserModel() {
      UserModel.__super__.constructor.apply(this, arguments);
    }

    return UserModel;

  })(Backbone.Model);

  NameDialog = (function(_super) {

    __extends(NameDialog, _super);

    function NameDialog() {
      NameDialog.__super__.constructor.apply(this, arguments);
    }

    NameDialog.prototype.initialize = function() {
      var _this = this;
      this.setElement($('#name-dialog'));
      return this.$('.btn.primary').click(function(e) {
        var name;
        console.log('Clicked');
        name = $.trim(_this.$('[name=user-name]').val());
        return $.post('/setName', {
          name: name
        }, function(err, resp) {
          _this.model.set({
            name: name
          });
          if (typeof _this.callback === "function") {
            _this.callback(_this.model.toJSON());
          }
          return _this.$el.modal('hide');
        });
      });
    };

    NameDialog.prototype.render = function() {
      return this;
    };

    NameDialog.prototype.show = function(callback) {
      this.callback = callback;
      this.$el.show().modal({
        backdrop: 'static',
        keyboard: false
      });
      return this.$('input').focus();
    };

    return NameDialog;

  })(Backbone.View);

  g_Dialog = null;

  exports.show = function(callback) {
    if (g_Dialog) {
      return g_Dialog.show(callback);
    } else {
      g_Dialog = new NameDialog({
        model: new UserModel
      });
      return g_Dialog.show(callback);
    }
  };

}).call(this);
