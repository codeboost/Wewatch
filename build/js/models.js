// Generated by IcedCoffeeScript 1.2.0s
(function() {
  var BookmarkItem, Bookmarks, ChatLinesCollection, OneChatLine, PlayItem, Playlist, UserCollection, VideoModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('models');
  }

  Backbone.Model.prototype.idAttribute = '_id';

  OneChatLine = (function(_super) {

    __extends(OneChatLine, _super);

    OneChatLine.name = 'OneChatLine';

    function OneChatLine() {
      return OneChatLine.__super__.constructor.apply(this, arguments);
    }

    return OneChatLine;

  })(Backbone.Model);

  ChatLinesCollection = (function(_super) {

    __extends(ChatLinesCollection, _super);

    ChatLinesCollection.name = 'ChatLinesCollection';

    function ChatLinesCollection() {
      return ChatLinesCollection.__super__.constructor.apply(this, arguments);
    }

    ChatLinesCollection.prototype.model = OneChatLine;

    return ChatLinesCollection;

  })(Backbone.Collection);

  VideoModel = (function(_super) {

    __extends(VideoModel, _super);

    VideoModel.name = 'VideoModel';

    function VideoModel() {
      return VideoModel.__super__.constructor.apply(this, arguments);
    }

    VideoModel.prototype.url = '/video';

    return VideoModel;

  })(Skull.Model);

  UserCollection = (function(_super) {

    __extends(UserCollection, _super);

    UserCollection.name = 'UserCollection';

    function UserCollection() {
      return UserCollection.__super__.constructor.apply(this, arguments);
    }

    UserCollection.prototype.url = '/users';

    return UserCollection;

  })(Skull.Collection);

  BookmarkItem = (function(_super) {

    __extends(BookmarkItem, _super);

    BookmarkItem.name = 'BookmarkItem';

    function BookmarkItem() {
      return BookmarkItem.__super__.constructor.apply(this, arguments);
    }

    BookmarkItem.prototype.defaults = {
      id_session: 0,
      videoId: '',
      start: 0,
      length: 0
    };

    return BookmarkItem;

  })(Skull.Model);

  Bookmarks = (function(_super) {

    __extends(Bookmarks, _super);

    Bookmarks.name = 'Bookmarks';

    function Bookmarks() {
      return Bookmarks.__super__.constructor.apply(this, arguments);
    }

    Bookmarks.prototype.url = '/bookmarks';

    Bookmarks.prototype.model = BookmarkItem;

    return Bookmarks;

  })(Skull.Collection);

  PlayItem = (function(_super) {

    __extends(PlayItem, _super);

    PlayItem.name = 'PlayItem';

    function PlayItem() {
      return PlayItem.__super__.constructor.apply(this, arguments);
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

    Playlist.name = 'Playlist';

    function Playlist() {
      return Playlist.__super__.constructor.apply(this, arguments);
    }

    Playlist.prototype.model = PlayItem;

    Playlist.prototype.url = '/playlist';

    Playlist.prototype.comparator = function(item) {
      var votes, _ref2, _ref3;
      votes = (_ref2 = (_ref3 = item.get('voters')) != null ? _ref3.length : void 0) != null ? _ref2 : 0;
      return -votes;
    };

    return Playlist;

  })(Skull.Collection);

  exports.init = function(ns, bootstrap) {
    var models, _ref2, _ref3, _ref4, _ref5;
    models = (_ref2 = WWM.models) != null ? _ref2 : WWM.models = {};
    ((_ref3 = models.video) != null ? _ref3 : models.video = ns.addModel(new VideoModel)).set(bootstrap.video);
    ((_ref4 = models.users) != null ? _ref4 : models.users = ns.addModel(new UserCollection)).reset(bootstrap.users);
    ((_ref5 = models.playlist) != null ? _ref5 : models.playlist = ns.addModel(new Playlist)).reset(bootstrap.playlist);
    if (models.chat == null) models.chat = new ChatLinesCollection;
    (models.bookmarks = ns.addModel(new Bookmarks)).reset(bootstrap.bookmarks);
    return models;
  };

}).call(this);
