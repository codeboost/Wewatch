(function() {
  var OnePlayItem, PlaylistView, Search, utils, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('playlist');
  }

  utils = require('utils');

  Search = require('search');

  OnePlayItem = (function(_super) {

    __extends(OnePlayItem, _super);

    function OnePlayItem() {
      this.render = __bind(this.render, this);
      this.thumbnailClicked = __bind(this.thumbnailClicked, this);
      this.removeItem = __bind(this.removeItem, this);
      OnePlayItem.__super__.constructor.apply(this, arguments);
    }

    OnePlayItem.prototype.tagName = 'tr';

    OnePlayItem.prototype.className = 'play-item';

    OnePlayItem.prototype.events = {
      'click .thumbnail': 'thumbnailClicked',
      'click': 'itemClicked',
      'click .remove': 'removeItem'
    };

    OnePlayItem.prototype.initialize = function() {
      var _this = this;
      this.template = utils.loadTemplate('one-play-item');
      this.model.bind('change', this.render);
      return this.model.bind('remove', function() {
        return _this.remove();
      });
    };

    OnePlayItem.prototype.removeItem = function(e) {
      e.preventDefault();
      this.model.destroy();
      return false;
    };

    OnePlayItem.prototype.thumbnailClicked = function(e) {
      var cur, userId, _ref2, _ref3;
      e.preventDefault();
      userId = WWM.user._id;
      cur = (_ref2 = (_ref3 = this.model.get('voters')) != null ? _ref3.slice() : void 0) != null ? _ref2 : new Array;
      if (cur.indexOf(userId) !== -1) return false;
      cur.push(userId);
      this.model.save({
        voters: cur
      });
      this.model.trigger('votes-changed', this.model);
      return false;
    };

    OnePlayItem.prototype.itemClicked = function() {
      return this.model.trigger('selected', this.model);
    };

    OnePlayItem.prototype.render = function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    };

    return OnePlayItem;

  })(Backbone.View);

  PlaylistView = (function(_super) {

    __extends(PlaylistView, _super);

    function PlaylistView() {
      this.render = __bind(this.render, this);
      this.addAll = __bind(this.addAll, this);
      this.addOne = __bind(this.addOne, this);
      PlaylistView.__super__.constructor.apply(this, arguments);
    }

    PlaylistView.prototype.initialize = function() {
      this.collection.bind('add', this.addOne);
      this.collection.bind('reset', this.addAll);
      return this.collection.bind('change:voters', this.collection.sort);
    };

    PlaylistView.prototype.addOne = function(item) {
      var view;
      view = new OnePlayItem({
        model: item
      });
      return this.$el.append(view.render().el);
    };

    PlaylistView.prototype.addAll = function() {
      this.$el.empty();
      return this.collection.each(this.addOne);
    };

    PlaylistView.prototype.render = function() {
      this.addAll();
      return this;
    };

    return PlaylistView;

  })(Backbone.View);

  exports.View = (function(_super) {

    __extends(View, _super);

    function View() {
      this.render = __bind(this.render, this);
      View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.initialize = function() {
      var _this = this;
      this.thumbnails = new PlaylistView({
        el: this.$('.playlist'),
        collection: this.collection
      });
      this.search = new Search.View({
        el: this.$('.search-view')
      });
      return this.search.bind('selected', function(model) {
        return _this.collection.create({
          thumbnail: model.get('thumbnail'),
          title: model.get('title'),
          url: 'http://www.youtube.com/watch?v=' + model.get('videoId'),
          uploader: model.get('uploader'),
          viewCount: model.get('viewCount'),
          position: 0,
          paused: false
        });
      });
    };

    View.prototype.render = function() {
      this.thumbnails.render();
      return this;
    };

    return View;

  })(Backbone.View);

}).call(this);
