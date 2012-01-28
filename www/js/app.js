(function() {
  var UserCollection, VideoModel, VideoView, connectToServer, extractVideoId, insertIframe, insertPlayer, saveVideoState,
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
    var _ref;
    return (_ref = url.match(/v=(.{11})/)) != null ? _ref[1] : void 0;
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
      this.model.bind('all', function() {
        return WWM.updating = false;
      });
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
        return WWM.Player.loadVideoById(videoId, this.model.get('position'));
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

  connectToServer = function() {
    var sio;
    sio = io.connect();
    sio.on('connect', function() {
      console.log('Connected to server');
      return sio.emit('join', WWM.session.id, function(err, data) {
        var Skull, globalNS, updateViewers, videoView;
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
        updateViewers = function() {
          return $('.viewers').text(WWM.models['users'].length + ' viewers');
        };
        WWM.models['users'].bind('all', updateViewers);
        return updateViewers();
      });
    });
    return $('.watch').click(function() {
      var url, videoId;
      url = $('[name=url]').val();
      videoId = extractVideoId(url);
      console.log('Setting new video URL: ', url);
      return WWM.Player.loadVideoById(videoId, 0);
    });
  };

  saveVideoState = function() {
    var url;
    console.log('Current getCurrentTime: ', WWM.Player.getCurrentTime());
    url = WWM.Player.getVideoUrl();
    return WWM.models['video'].save({
      paused: WWM.Player.getPlayerState() === YT.PlayerState.PAUSED,
      position: Math.round(WWM.Player.getCurrentTime()),
      url: url
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
          if (!WWM.connected) return;
          console.log('State changed: ', e.data);
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

  $(function() {
    insertIframe();
    return $('.change-video').click(function() {
      $('.url-form').toggleClass('hidden');
      return $('.url-form input').focus();
    });
  });

}).call(this);
