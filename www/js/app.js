(function() {
  var UserCollection, VideoModel, VideoView, ViewersView, connectToServer, extractVideoId, insertIframe, insertPlayer, saveVideoState,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  insertIframe = function() {
    var firstTag, tag;
    tag = document.createElement('script');
    tag.src = 'http://www.youtube.com/player_api';
    firstTag = document.getElementsByTagName('script')[0];
    return firstTag.parentNode.insertBefore(tag, firstTag);
  };

  extractVideoId = function(url) {
    var _ref, _ref2;
    return (_ref = url.match(/v=(.{11})/)) != null ? (_ref2 = _ref[1]) != null ? _ref2.replace(/[^a-z0-9]/ig, '') : void 0 : void 0;
  };

  WWM.Player = null;

  VideoModel = (function(_super) {

    __extends(VideoModel, _super);

    function VideoModel() {
      VideoModel.__super__.constructor.apply(this, arguments);
    }

    VideoModel.prototype.url = '/video';

    return VideoModel;

  })(Skull.Model);

  UserCollection = (function(_super) {

    __extends(UserCollection, _super);

    function UserCollection() {
      UserCollection.__super__.constructor.apply(this, arguments);
    }

    UserCollection.prototype.url = '/users';

    return UserCollection;

  })(Skull.Collection);

  VideoView = (function(_super) {

    __extends(VideoView, _super);

    function VideoView() {
      this.seek = __bind(this.seek, this);
      this.changeUrl = __bind(this.changeUrl, this);
      this.pausedChanged = __bind(this.pausedChanged, this);
      VideoView.__super__.constructor.apply(this, arguments);
    }

    VideoView.prototype.initialize = function() {
      this.model.bind('change:url', this.changeUrl);
      this.model.bind('change:position', this.seek);
      this.model.bind('change:paused', this.pausedChanged);
      return this.changeUrl();
    };

    VideoView.prototype.pausedChanged = function() {
      var isPaused;
      isPaused = this.model.get('paused');
      if (isPaused) {
        if (WWM.Player.getPlayerState() !== YT.PlayerState.PAUSED) {
          return WWM.Player.pauseVideo();
        }
      } else {
        if (WWM.Player.getPlayerState() !== YT.PlayerState.PLAYING) {
          return WWM.Player.playVideo();
        }
      }
    };

    VideoView.prototype.changeUrl = function() {
      var videoId;
      videoId = extractVideoId(this.model.get('url'));
      if (videoId) {
        this.loadVideo(videoId);
        return this.seek();
      }
    };

    VideoView.prototype.seek = function() {
      console.log('-> Seeking to ', this.model.get('position'));
      WWM.Player.seekTo(this.model.get('position'), true);
      return console.log('Current position: ', WWM.Player.getCurrentTime());
    };

    VideoView.prototype.loadVideo = function(videoId) {
      return WWM.Player.loadVideoById(videoId);
    };

    return VideoView;

  })(Backbone.View);

  ViewersView = (function(_super) {

    __extends(ViewersView, _super);

    function ViewersView() {
      this.updateViewers = __bind(this.updateViewers, this);
      ViewersView.__super__.constructor.apply(this, arguments);
    }

    ViewersView.prototype.initialize = function() {
      this.collection.bind('change', this.updateViewers);
      return this.updateViewers();
    };

    ViewersView.prototype.updateViewers = function() {
      return $(this.el).text(this.collection.length + ' viewers');
    };

    return ViewersView;

  })(Backbone.View);

  connectToServer = function() {
    var sio;
    sio = io.connect();
    sio.on('connect', function() {
      console.log('Connected to server');
      return sio.emit('join', WWM.session.id, function(err, data) {
        var Skull, globalNS, videoView;
        console.log('Joined session');
        WWM.connected = true;
        Skull = require('skull');
        globalNS = Skull.createClient(sio.of(WWM.session.id));
        WWM.models = {};
        WWM.models['video'] = globalNS.addModel(new VideoModel(data.video));
        WWM.models['users'] = globalNS.addModel(new UserCollection(data.users));
        videoView = new VideoView({
          model: WWM.models.video
        });
        $('.viewers').text(WWM.models['users'].length + ' viewers');
        return WWM.models['users'].bind('all', function() {
          return $('.viewers').text(WWM.models['users'].length + ' viewers');
        });
      });
    });
    return $('.watch').click(function() {
      var url, videoId;
      url = $('[name=url]').val();
      videoId = extractVideoId(url);
      return WWM.models['video'].save({
        url: url
      });
    });
  };

  $(function() {
    console.log('Document ready');
    return insertIframe();
  });

  saveVideoState = function() {
    console.log('Current getCurrentTime: ', WWM.Player.getCurrentTime());
    return WWM.models['video'].save({
      paused: WWM.Player.getPlayerState() === YT.PlayerState.PAUSED,
      position: Math.round(WWM.Player.getCurrentTime())
    }, {
      silent: true
    });
  };

  insertPlayer = function() {
    var player, timerId;
    timerId = 0;
    $('#player').replaceWith('<div id="player"></div>');
    return player = new YT.Player('player', {
      height: 390,
      width: 780,
      events: {
        'onReady': function(event) {
          console.log('Player ready');
          WWM.Player = event.target;
          return connectToServer();
        },
        'onStateChange': function(e) {
          console.log('State changed: ', e.data);
          if (!WWM.connected) return;
          if (WWM.models['video'].get('owner') === WWM.user.id) {
            if (e.data === YT.PlayerState.PLAYING) {
              clearTimeout(timerId);
              timerId = setTimeout(saveVideoState, 150);
              console.log('StateChanged getCurrentTime: ', Math.round(WWM.Player.getCurrentTime()));
            }
            if (e.data === YT.PlayerState.PAUSED) {
              clearTimeout(timerId);
              return timerId = setTimeout(saveVideoState, 150);
            }
          }
        }
      }
    });
  };

  window.onYouTubePlayerAPIReady = function() {
    console.log('Youtube player API ready!');
    return insertPlayer();
  };

}).call(this);
