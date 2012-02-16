(function() {
  var ChatView, Messages, OneChatView, utils, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if ((_ref = window.module) != null) _ref.enter('chat');

  utils = require('utils');

  OneChatView = (function(_super) {

    __extends(OneChatView, _super);

    function OneChatView() {
      this.render = __bind(this.render, this);
      OneChatView.__super__.constructor.apply(this, arguments);
    }

    OneChatView.prototype.tagName = 'li';

    OneChatView.prototype.initialize = function() {
      this.template = utils.loadTemplate('one-chat-item');
      return this.model.bind('change', this.render);
    };

    OneChatView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    };

    return OneChatView;

  })(Backbone.View);

  Messages = (function(_super) {

    __extends(Messages, _super);

    function Messages() {
      this.addOne = __bind(this.addOne, this);
      Messages.__super__.constructor.apply(this, arguments);
    }

    Messages.prototype.initialize = function() {
      this.collection.bind('add', this.addOne);
      return this.collection.bind('reset', this.addAll);
    };

    Messages.prototype.addOne = function(item) {
      var view;
      view = new OneChatView({
        model: item
      });
      return this.$el.prepend(view.render().el);
    };

    Messages.prototype.addAll = function(items) {
      this.$el.empty();
      return this.collection.each(this.addOne);
    };

    Messages.prototype.render = function() {
      this.addAll();
      return this;
    };

    return Messages;

  })(Backbone.View);

  exports.View = ChatView = (function(_super) {

    __extends(ChatView, _super);

    function ChatView() {
      this.onChatKeyUp = __bind(this.onChatKeyUp, this);
      ChatView.__super__.constructor.apply(this, arguments);
    }

    ChatView.prototype.events = {
      'keyup input.chat-message': 'onChatKeyUp'
    };

    ChatView.prototype.initialize = function() {
      this.messages = new Messages({
        el: this.$('.messages'),
        collection: this.collection
      });
      this.chatInput = this.$('[name=chat-message]');
      return this.messages.render();
    };

    ChatView.prototype.onChatKeyUp = function(e) {
      var data, txt;
      if (e.keyCode === 13) {
        txt = $.trim(this.chatInput.val());
        if (!txt.length) return;
        data = {
          from: WWM.user.name,
          message: txt
        };
        this.collection.trigger('new-msg', data);
        data.message = _.escape(txt);
        this.collection.add(data);
        return this.chatInput.val('');
      }
    };

    return ChatView;

  })(Backbone.View);

}).call(this);
