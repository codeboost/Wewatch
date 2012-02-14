(function() {
  var ChatLinesCollection, OneChatLine, PlayItem, Playlist, UserCollection, VideoModel, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('models');
  }

  Backbone.Model.prototype.idAttribute = '_id';

  OneChatLine = (function(_super) {

    __extends(OneChatLine, _super);

    function OneChatLine() {
      OneChatLine.__super__.constructor.apply(this, arguments);
    }

    return OneChatLine;

  })(Backbone.Model);

  ChatLinesCollection = (function(_super) {

    __extends(ChatLinesCollection, _super);

    function ChatLinesCollection() {
      ChatLinesCollection.__super__.constructor.apply(this, arguments);
    }

    ChatLinesCollection.prototype.model = OneChatLine;

    return ChatLinesCollection;

  })(Backbone.Collection);

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

  PlayItem = (function(_super) {

    __extends(PlayItem, _super);

    function PlayItem() {
      PlayItem.__super__.constructor.apply(this, arguments);
    }

    PlayItem.prototype.defaults = {
      url: '',
      thumbnail: '',
      position: 0,
      uploader: 'dj sample',
      viewCount: 345,
      paused: false,
      votes: 0,
      voters: null
    };

    return PlayItem;

  })(Skull.Model);

  Playlist = (function(_super) {

    __extends(Playlist, _super);

    function Playlist() {
      Playlist.__super__.constructor.apply(this, arguments);
    }

    Playlist.prototype.model = PlayItem;

    Playlist.prototype.url = '/playlist';

    Playlist.prototype.comparator = function(item) {
      var votes, _ref2, _ref3;
      votes = (_ref2 = (_ref3 = item.get('voters')) != null ? _ref3.length : void 0) != null ? _ref2 : 0;
      return -votes;
    };

    exports.init = function(ns, bootstrap) {
      var models;
      models = {};
      models['video'] = ns.addModel(new VideoModel(bootstrap.video));
      models['users'] = ns.addModel(new UserCollection(bootstrap.users));
      models['playlist'] = ns.addModel(new Playlist(bootstrap.playlist));
      models['chat'] = new ChatLinesCollection;
      return models;
    };

    return Playlist;

  })(Skull.Collection);

}).call(this);
