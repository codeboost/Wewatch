(function() {
  var utils, yt, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if ((_ref = window.module) != null) _ref.enter('playerView');

  utils = require('utils');

  yt = require('yt');

  exports.PlayerView = (function(_super) {

    __extends(PlayerView, _super);

    function PlayerView() {
      this.seek = __bind(this.seek, this);
      this.onShow = __bind(this.onShow, this);
      this.changeUrl = __bind(this.changeUrl, this);
      this.pausedChanged = __bind(this.pausedChanged, this);
      this.saveState = __bind(this.saveState, this);
      this.delaySaveState = __bind(this.delaySaveState, this);
      PlayerView.__super__.constructor.apply(this, arguments);
    }

    PlayerView.prototype.initialize = function() {
      var _this = this;
      this.model.bind('change:url', this.changeUrl);
      this.model.bind('change:position', this.seek);
      this.model.bind('change:paused', this.pausedChanged);
      this.player = new yt.Player({
        controls: WWM.isModerator
      });
      this.player.state.bind('ready', function() {
        return _this.changeUrl();
      });
      this.st = 0;
      this.player.insertPlayer();
      this.player.bind('playing', function() {
        console.log('~ Playing');
        return _this.delaySaveState();
      });
      this.player.bind('paused', function() {
        console.log('~ Paused');
        return _this.delaySaveState();
      });
      return this.player.bind('seeked', function() {
        console.log('~ Seeked');
        return _this.delaySaveState();
      });
    };

    PlayerView.prototype.delaySaveState = function() {
      clearTimeout(this.st);
      if (WWM.isModerator) return this.st = _.delay(this.saveState, 150);
    };

    PlayerView.prototype.saveState = function() {
      var state;
      if (this.changingURL) return;
      state = {
        paused: this.player.isPaused(),
        position: this.player.getCurrentTime(),
        url: this.player.getVideoUrl()
      };
      console.log('*Saving state: ', state);
      return this.model.save(state, {
        silent: true
      });
    };

    PlayerView.prototype.pausedChanged = function() {
      if (this.model.get('paused')) {
        if (!this.player.isPaused()) return this.player.pauseVideo();
      } else {
        if (!(this.player.isPlaying() && !WWM.idle)) {
          return this.player.playVideo();
        }
      }
    };

    PlayerView.prototype.changeUrl = function() {
      var videoId;
      console.log('Change URL: ' + this.model.get('url') + ' -> ' + this.model.get('position'));
      videoId = utils.extractVideoId(this.model.get('url'));
      if (videoId) {
        this.changingURL = true;
        this.player.cueVideoById(videoId, this.model.get('position'));
        this.seek();
        if (this.model.get('paused')) this.player.pauseVideo();
        return this.changingURL = false;
      }
    };

    PlayerView.prototype.onShow = function() {
      return this.seek();
    };

    PlayerView.prototype.seek = function() {
      if (WWM.idle) return;
      return this.player.seekTo(this.model.get('position'), true);
    };

    return PlayerView;

  })(Backbone.View);

}).call(this);
