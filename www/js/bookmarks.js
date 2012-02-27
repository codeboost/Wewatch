(function() {
  var ManyBookmarks, OneBookmarkItem, View, secondsToTime, utils, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('bookmarks');
  }

  utils = require('utils');

  secondsToTime = function(secs) {
    var dvm, dvs, hours, mins, ret;
    hours = Math.floor(secs / 3600);
    dvm = secs % 3600;
    mins = Math.floor(dvm / 60);
    dvs = dvm % 60;
    secs = Math.ceil(dvs);
    return ret = {
      h: hours,
      m: mins,
      s: secs
    };
  };

  OneBookmarkItem = (function(_super) {

    __extends(OneBookmarkItem, _super);

    function OneBookmarkItem() {
      this.render = __bind(this.render, this);
      this.removeItem = __bind(this.removeItem, this);
      OneBookmarkItem.__super__.constructor.apply(this, arguments);
    }

    OneBookmarkItem.prototype.tagName = 'tr';

    OneBookmarkItem.prototype.className = 'play-item';

    OneBookmarkItem.prototype.events = {
      'click': 'itemClicked',
      'click .remove': 'removeItem'
    };

    OneBookmarkItem.prototype.initialize = function() {
      var _this = this;
      this.template = utils.loadTemplate('one-bookmark-item');
      this.model.bind('change', this.render);
      return this.model.bind('remove', function() {
        return _this.remove();
      });
    };

    OneBookmarkItem.prototype.removeItem = function(e) {
      e.preventDefault();
      this.model.destroy();
      return false;
    };

    OneBookmarkItem.prototype.itemClicked = function() {
      return this.model.trigger('selected', this.model);
    };

    OneBookmarkItem.prototype.modelData = function() {
      var st, sto, vid;
      vid = this.model.toJSON();
      st = secondsToTime(vid.position);
      sto = [];
      if (st.h > 0) sto.push(st.h);
      sto.push(st.m);
      sto.push(st.s);
      vid.startTime = sto.join(':');
      return vid;
    };

    OneBookmarkItem.prototype.render = function() {
      $(this.el).html(this.template(this.modelData()));
      return this;
    };

    return OneBookmarkItem;

  })(Backbone.View);

  ManyBookmarks = (function(_super) {

    __extends(ManyBookmarks, _super);

    function ManyBookmarks() {
      this.render = __bind(this.render, this);
      this.addAll = __bind(this.addAll, this);
      this.addOne = __bind(this.addOne, this);
      ManyBookmarks.__super__.constructor.apply(this, arguments);
    }

    ManyBookmarks.prototype.initialize = function() {
      this.collection.bind('add', this.addOne);
      return this.collection.bind('reset', this.addAll);
    };

    ManyBookmarks.prototype.addOne = function(item) {
      var view;
      view = new OneBookmarkItem({
        model: item
      });
      return this.$el.append(view.render().el);
    };

    ManyBookmarks.prototype.addAll = function() {
      this.$el.empty();
      return this.collection.each(this.addOne);
    };

    ManyBookmarks.prototype.render = function() {
      this.addAll();
      return this;
    };

    return ManyBookmarks;

  })(Backbone.View);

  exports.View = View = (function(_super) {

    __extends(View, _super);

    function View() {
      this.initialize = __bind(this.initialize, this);
      View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.initialize = function() {
      this.bookmarks = new ManyBookmarks({
        collection: this.collection,
        el: this.$('.bookmarks')
      });
      return this.bookmarks.addAll();
    };

    return View;

  })(Backbone.View);

}).call(this);