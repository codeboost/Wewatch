(function() {
  var PlayerState, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if ((_ref = window.module) != null) _ref.enter('yt');

  exports.PlayerState = PlayerState = (function(_super) {

    __extends(PlayerState, _super);

    function PlayerState() {
      PlayerState.__super__.constructor.apply(this, arguments);
    }

    PlayerState.prototype.defaults = {
      ready: false,
      state: 0,
      error: ''
    };

    return PlayerState;

  })(Backbone.Model);

  exports.Player = (function(_super) {

    __extends(Player, _super);

    function Player() {
      this.isPlaying = __bind(this.isPlaying, this);
      this.isPaused = __bind(this.isPaused, this);
      this.marshall = __bind(this.marshall, this);
      Player.__super__.constructor.apply(this, arguments);
    }

    Player.prototype.initialize = function() {
      var _ref2;
      this.state = new PlayerState;
      this.idPlayer = (_ref2 = this.options.idPlayer) != null ? _ref2 : 'player';
      return this.state.bind('change:ready', this.marshall);
    };

    Player.prototype.marshall = function() {
      var fn, _i, _len, _ref2, _results;
      _ref2 = 'cueVideoById\nloadVideoById\nseekTo\nplayVideo\npauseVideo\ngetPlayerState\ngetVideoUrl'.split('\n');
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        fn = _ref2[_i];
        _results.push(this[fn] = _.bind(this.player[fn], this.player));
      }
      return _results;
    };

    Player.prototype.isPaused = function() {
      return this.player.getPlayerState() === YT.PlayerState.PAUSED;
    };

    Player.prototype.isPlaying = function() {
      return this.player.getPlayerState() === YT.PlayerState.PLAYING;
    };

    Player.prototype.getCurrentTime = function() {
      return Math.round(this.player.getCurrentTime());
    };

    Player.prototype.insertPlayer = function() {
      var playerState, _ref2, _ref3,
        _this = this;
      playerState = this.state;
      return this.player = new YT.Player(this.idPlayer, {
        height: (_ref2 = this.options.height) != null ? _ref2 : 390,
        width: (_ref3 = this.options.width) != null ? _ref3 : '100%',
        playerVars: {
          'autoplay': 0,
          'controls': this.options.controls ? '1' : '0'
        },
        events: {
          onReady: function() {
            playerState.set({
              ready: true
            });
            return playerState.trigger('ready');
          },
          onStateChange: function(event) {
            var prevState;
            prevState = playerState.get('state');
            playerState.set({
              state: event.data
            });
            switch (event.data) {
              case YT.PlayerState.PLAYING:
                if (prevState === YT.PlayerState.PLAYING) {
                  return _this.trigger('seeked');
                } else {
                  return _this.trigger('playing');
                }
                break;
              case YT.PlayerState.PAUSED:
                if (prevState === YT.PlayerState.PAUSED) {
                  return _this.trigger('seeked');
                } else {
                  return _this.trigger('playing');
                }
            }
          },
          onError: function(err) {
            return playerState.set({
              error: (function() {
                switch (err) {
                  case 2:
                    return 'Invalid parameters';
                  case 100:
                    return 'Video not found';
                  case 101 || 150:
                    return 'Video cannot be embedded';
                  default:
                    return 'Unknown error';
                }
              })()
            });
          }
        }
      });
    };

    return Player;

  })(Backbone.View);

}).call(this);
