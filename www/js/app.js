(function() {
  var AppView, Chat, NameDialog, PlayerView, Playlist, Skull, createYTFrame, ioState, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('app');
  }

  ioState = require('ioState');

  Playlist = require('playlist');

  PlayerView = require('playerView');

  NameDialog = require('name-dialog');

  Chat = require('chat');

  try {
    Skull = require('skull-client');
  } catch (e) {
    Skull = require('skull');
  }

  WWM.Player = null;

  WWM.isModerator = WWM.session.creator === WWM.user._id;

  WWM.playbackState = 'playing';

  AppView = (function(_super) {

    __extends(AppView, _super);

    function AppView() {
      this.updateViewers = __bind(this.updateViewers, this);
      AppView.__super__.constructor.apply(this, arguments);
    }

    AppView.prototype.initialize = function() {
      this.el = $('#main-container');
      this.playerView = new PlayerView.PlayerView({
        model: WWM.models.video
      });
      this.playlistView = new Playlist.View({
        collection: WWM.models.playlist,
        el: this.$('.playlist-view')
      });
      this.playlistView.collection.bind('selected', function(model) {
        console.log('Selected: ', model.toJSON());
        return WWM.models.video.save(model.toJSON());
      });
      this.chatView = new Chat.View({
        el: this.$('.chat-view'),
        collection: WWM.models.chat
      });
      WWM.models.users.bind('all', this.updateViewers);
      WWM.models.users.bind('server-broadcast', function(data) {
        return WWM.models.chat.add(data);
      });
      WWM.models.chat.bind('new-msg', function(data) {
        return WWM.models.users.broadcast(data);
      });
      this.playlistView.render();
      return this.updateViewers();
    };

    AppView.prototype.updateViewers = function() {
      return this.$('.viewers').text(WWM.models.users.length + ' viewers');
    };

    AppView.prototype.show = function() {
      this.el.show();
      return this;
    };

    return AppView;

  })(Backbone.View);

  createYTFrame = function() {
    var firstTag, tag;
    tag = document.createElement('script');
    tag.src = 'http://www.youtube.com/player_api';
    firstTag = document.getElementsByTagName('script')[0];
    return firstTag.parentNode.insertBefore(tag, firstTag);
  };

  window.onYouTubePlayerAPIReady = function() {
    var model;
    console.log('Youtube player API ready!');
    console.log('Connecting to server');
    model = new Backbone.Model({
      name: 'Maria',
      age: 16
    });
    model.bind('change:name', function(newv) {
      return console.log('Name is ' + this.get('name') + ' and age is ' + this.get('age'));
    });
    model.set({
      name: 'John',
      age: 23
    });
    WWM.conn = new ioState.ConnectionState;
    WWM.conn.bind('joined', function(bootstrap) {
      var globalNS, _ref2;
      globalNS = Skull.createClient(WWM.conn.sio.of(WWM.session._id));
      WWM.models = require('models').init(globalNS, bootstrap);
      if ((_ref2 = WWM.user.name) != null ? _ref2.length : void 0) {
        return (new AppView).show();
      }
      return NameDialog.show(function(mdl) {
        return (new AppView).show();
      });
    });
    return WWM.conn.join(WWM.session.docid);
  };

  exports.start = function() {
    return $(function() {
      return createYTFrame();
    });
  };

}).call(this);
