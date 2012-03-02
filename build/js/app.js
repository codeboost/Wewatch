// Generated by IcedCoffeeScript 1.2.0i
(function() {
  var AppView, Bookmarks, Chat, ConnectionView, NameDialog, PlayerView, Playlist, RighSide, VideoInfo, createYTFrame, ioState, updateModels, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('app');
  }

  ioState = require('ioState');

  Playlist = require('playlist');

  PlayerView = require('playerView');

  NameDialog = require('name-dialog');

  Chat = require('chat');

  Bookmarks = require('bookmarks');

  WWM.Player = null;

  WWM.isModerator = WWM.session.creator === WWM.user._id;

  WWM.initialized = false;

  WWM.paused = false;

  RighSide = (function(_super) {

    __extends(RighSide, _super);

    RighSide.name = 'RighSide';

    function RighSide() {
      this.render = __bind(this.render, this);

      this.selectPlaylist = __bind(this.selectPlaylist, this);

      this.selectBookmarks = __bind(this.selectBookmarks, this);
      return RighSide.__super__.constructor.apply(this, arguments);
    }

    RighSide.prototype.events = {
      'click .select-bookmarks': 'selectBookmarks',
      'click .select-playlist': 'selectPlaylist'
    };

    RighSide.prototype.initialize = function() {
      this.playlist = new Playlist.View({
        collection: WWM.models.playlist,
        el: this.$('.playlist-view')
      });
      this.bookmarks = new Bookmarks.View({
        collection: WWM.models.bookmarks,
        el: this.$('.bookmarks-view')
      });
      this.tabs = {
        bookmarks: this.$('.select-bookmarks'),
        playlist: this.$('.select-playlist')
      };
      return this.curView = this.playlist;
    };

    RighSide.prototype.selectBookmarks = function(e) {
      if (e != null) e.preventDefault();
      this.playlist.$el.hide();
      this.bookmarks.$el.show();
      this.tabs.bookmarks.addClass('active');
      this.tabs.playlist.removeClass('active');
      return this.curView = this.bookmarks;
    };

    RighSide.prototype.selectPlaylist = function(e) {
      if (e != null) e.preventDefault();
      this.bookmarks.$el.hide();
      this.playlist.$el.show();
      this.tabs.bookmarks.removeClass('active');
      this.tabs.playlist.addClass('active');
      return this.curView = this.playlist;
    };

    RighSide.prototype.render = function() {
      return this.curView.render();
    };

    return RighSide;

  })(Backbone.View);

  VideoInfo = (function(_super) {

    __extends(VideoInfo, _super);

    VideoInfo.name = 'VideoInfo';

    function VideoInfo() {
      this.update = __bind(this.update, this);

      this.updateViewers = __bind(this.updateViewers, this);
      return VideoInfo.__super__.constructor.apply(this, arguments);
    }

    VideoInfo.prototype.initialize = function() {
      this.title = this.$('.video-title');
      this.viewers = this.$('.viewers');
      this.totalViews = this.$('.total-views');
      this.model.bind('change', this.update);
      this.options.usersModel.bind('all', this.updateViewers);
      this.update();
      return this.updateViewers();
    };

    VideoInfo.prototype.updateViewers = function() {
      var active, fnReduce, total;
      total = this.options.usersModel.length;
      fnReduce = function(memo, item) {
        if (item.get('idle')) {
          return memo;
        } else {
          return memo + 1;
        }
      };
      active = this.options.usersModel.reduce(fnReduce, 0);
      return this.viewers.text(active + '/' + total + ' viewers');
    };

    VideoInfo.prototype.update = function() {
      var presenter, ret, viewCount, _ref2, _ref3;
      if (WWM.isModerator) {
        this.title.text('You are presenting');
        this.$('.search-view').show();
        this.$('.right-side').show();
      } else {
        ret = this.options.usersModel.filter(function(usr) {
          return WWM.session.creator === usr.get('id_user');
        });
        presenter = (_ref2 = ret != null ? (_ref3 = ret[0]) != null ? _ref3.get('name') : void 0 : void 0) != null ? _ref2 : 'No one';
        this.title.text(presenter + ' is presenting');
      }
      viewCount = this.model.get('viewCount');
      viewCount = viewCount ? viewCount + ' views' : '0';
      return this.totalViews.text(viewCount);
    };

    return VideoInfo;

  })(Backbone.View);

  ConnectionView = (function(_super) {

    __extends(ConnectionView, _super);

    ConnectionView.name = 'ConnectionView';

    function ConnectionView() {
      this.update = __bind(this.update, this);
      return ConnectionView.__super__.constructor.apply(this, arguments);
    }

    ConnectionView.prototype.initialize = function() {
      return this.model.bind('change', this.update);
    };

    ConnectionView.prototype.update = function() {
      var state;
      state = this.model.get('state');
      if (state === 'disconnected') {
        return this.$el.show();
      } else {
        return this.$el.hide();
      }
    };

    return ConnectionView;

  })(Backbone.View);

  AppView = (function(_super) {

    __extends(AppView, _super);

    AppView.name = 'AppView';

    function AppView() {
      return AppView.__super__.constructor.apply(this, arguments);
    }

    AppView.prototype.events = {
      'click .mark-in': 'markIn',
      'click .mark-out': 'markOut'
    };

    AppView.prototype.initialize = function() {
      this.setElement($('#main-container'));
      this.connectionView = new ConnectionView({
        el: $('.connection-view'),
        model: WWM.conn
      });
      this.videoInfo = new VideoInfo({
        el: this.el,
        model: WWM.models.video,
        usersModel: WWM.models.users
      });
      this.playerView = new PlayerView.PlayerView({
        model: WWM.models.video
      });
      this.rightSide = new RighSide({
        el: this.$('.right-side')
      });
      this.chatView = new Chat.View({
        el: this.$('.chat-view'),
        collection: WWM.models.chat
      });
      $(window).blur(function() {
        var myModel, _ref2;
        myModel = WWM.models.users.filter(function(viewer) {
          return viewer.get('id_user') === WWM.user._id;
        });
        if (myModel != null) {
          if ((_ref2 = myModel[0]) != null) {
            _ref2.save({
              idle: true
            });
          }
        }
        return WWM.idle = true;
      });
      $(window).focus(function() {
        var myModel, _ref2;
        myModel = WWM.models.users.filter(function(viewer) {
          return viewer.get('id_user') === WWM.user._id;
        });
        if (myModel != null) {
          if ((_ref2 = myModel[0]) != null) {
            _ref2.save({
              idle: false
            });
          }
        }
        return WWM.idle = false;
      });
      this.editButtons = {
        markIn: this.$('.mark-in'),
        markOut: this.$('.mark-out')
      };
      this.rightSide.render();
      return WWM.initialized = true;
    };

    AppView.prototype.markIn = function() {
      var point;
      if (!WWM.isModerator) return;
      this.rightSide.selectBookmarks();
      point = WWM.models.video.toJSON();
      delete point._id;
      point.position = this.playerView.player.getCurrentTime();
      return this.lastPoint = WWM.models.bookmarks.create(point);
    };

    AppView.prototype.markOut = function() {
      var curPos, len, startPos;
      if (!WWM.isModerator) return;
      if (!this.lastPoint) return;
      this.rightSide.selectBookmarks();
      startPos = this.lastPoint.get('position');
      curPos = this.playerView.player.getCurrentTime();
      len = curPos - startPos;
      if (!(len > 0)) return;
      this.lastPoint.save({
        length: len
      });
      return this.lastPoint = null;
    };

    AppView.prototype.show = function() {
      this.$el.show();
      return this;
    };

    return AppView;

  })(Backbone.View);

  WWM.bindEvents = function() {
    WWM.models.playlist.bind('selected', function(model) {
      var vid;
      if (!WWM.isModerator) return;
      vid = model.toJSON();
      console.log('Selected: ', vid);
      delete vid._id;
      return WWM.models.video.set(vid);
    });
    WWM.models.users.bind('server-broadcast', function(data) {
      return WWM.models.chat.add(data);
    });
    WWM.models.chat.bind('new-msg', function(data) {
      return WWM.models.users.broadcast(data);
    });
    return WWM.models.bookmarks.bind('selected', function(model) {
      var vid;
      if (!WWM.isModerator) return;
      vid = model.toJSON();
      delete vid._id;
      return WWM.models.video.set(vid);
    });
  };

  createYTFrame = function() {
    var firstTag, tag;
    tag = document.createElement('script');
    tag.src = 'http://www.youtube.com/player_api';
    firstTag = document.getElementsByTagName('script')[0];
    return firstTag.parentNode.insertBefore(tag, firstTag);
  };

  updateModels = function(bootstrap) {
    WWM.models.video.set(bootstrap.video);
    WWM.models.users.reset(bootstrap.users);
    return WWM.models.playlist.reset(bootstrap.playlist);
  };

  window.onYouTubePlayerAPIReady = function() {
    WWM.conn = new ioState.ConnectionState;
    WWM.conn.bind('joined', function(bootstrap) {
      var globalNS, ns, _ref2;
      ns = WWM.conn.sio.of(WWM.session._id);
      globalNS = Skull.createClient(ns);
      require('models').init(globalNS, bootstrap);
      WWM.bindEvents();
      if (WWM.initialized) return;
      if ((_ref2 = WWM.user.name) != null ? _ref2.length : void 0) {
        return (new AppView).show();
      }
      return NameDialog.show(function(mdl) {
        WWM.user.name = mdl.name;
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
