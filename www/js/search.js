(function() {
  var OneSearchItem, OneSearchItemView, SearchResultsCollection, SearchView, utils, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('search');
  }

  utils = require('utils');

  OneSearchItem = (function(_super) {

    __extends(OneSearchItem, _super);

    function OneSearchItem() {
      OneSearchItem.__super__.constructor.apply(this, arguments);
    }

    return OneSearchItem;

  })(Backbone.Model);

  SearchResultsCollection = (function(_super) {

    __extends(SearchResultsCollection, _super);

    function SearchResultsCollection() {
      SearchResultsCollection.__super__.constructor.apply(this, arguments);
    }

    SearchResultsCollection.prototype.model = OneSearchItem;

    return SearchResultsCollection;

  })(Backbone.Collection);

  OneSearchItemView = (function(_super) {

    __extends(OneSearchItemView, _super);

    function OneSearchItemView() {
      this.render = __bind(this.render, this);
      OneSearchItemView.__super__.constructor.apply(this, arguments);
    }

    OneSearchItemView.prototype.tagName = 'tr';

    OneSearchItemView.prototype.className = 'search-item';

    OneSearchItemView.prototype.initialize = function() {
      this.template = utils.loadTemplate('one-search-item');
      return this.model.bind('change', this.render);
    };

    OneSearchItemView.prototype.render = function() {
      $(this.el).html(this.template(this.model.toJSON()));
      $(this.el).attr('id_model', this.model.get('videoId'));
      return this;
    };

    return OneSearchItemView;

  })(Backbone.View);

  exports.View = SearchView = (function(_super) {

    __extends(SearchView, _super);

    function SearchView() {
      this.addAll = __bind(this.addAll, this);
      this.addOne = __bind(this.addOne, this);
      this.performSearch = __bind(this.performSearch, this);
      this.showSearchResults = __bind(this.showSearchResults, this);
      this.oninputkeyup = __bind(this.oninputkeyup, this);
      this.onclickselected = __bind(this.onclickselected, this);
      this.onkeyup = __bind(this.onkeyup, this);
      SearchView.__super__.constructor.apply(this, arguments);
    }

    SearchView.prototype.OneItemView = OneSearchItemView;

    SearchView.prototype.events = {
      'keyup input': 'oninputkeyup',
      'mouseover tr': 'onmouseover',
      'mouseout tr': 'onmouseout',
      'click tr': 'onclickselected',
      'keyup': 'onkeyup'
    };

    SearchView.prototype.initialize = function() {
      var _this = this;
      if (this.domEl) this.el = $($(this.domEl).html());
      this.collection = new SearchResultsCollection;
      this.collection.bind('add', this.addOne);
      this.collection.bind('reset', this.addAll);
      this.searchResults = this.$('.search-place');
      this.items = $('.search-results', this.searchResults);
      this.input = this.$('.search-video');
      this.searchTimer = 0;
      $(document).bind('click', function(e) {
        if ($(e.target).is('input.search-video')) return;
        return _this.searchResults.hide();
      });
      return this.input.focus(function(e) {
        return _this.showSearchResults();
      });
    };

    SearchView.prototype.onmouseover = function(e) {
      return $(e.currentTarget).addClass('selected');
    };

    SearchView.prototype.onmouseout = function(e) {
      return $(e.currentTarget).removeClass('selected');
    };

    SearchView.prototype.onkeyup = function(e) {
      if (e.keyCode === 27) {
        this.searchResults.hide();
        false;
      }
      if (e.keyCode === 13) {
        this.onclickselected();
        return false;
      }
    };

    SearchView.prototype.onclickselected = function() {
      var id, model;
      console.log('Click selected!');
      id = this.getSelected().attr('id_model');
      model = this.collection.find(function(item) {
        return item.get('videoId') === id;
      });
      this.trigger('selected', model);
      return this.searchResults.hide();
    };

    SearchView.prototype.getSelected = function() {
      var cur;
      cur = this.$('.selected');
      if (cur.length === 0) cur = this.$('li:first');
      return cur;
    };

    SearchView.prototype.selectNext = function() {
      var cur, next;
      if (!(cur = this.getSelected())) return;
      next = cur.next();
      if (next.length === 0) next = this.$('li:first');
      cur.removeClass('selected');
      return next.addClass('selected');
    };

    SearchView.prototype.selectPrev = function() {
      var cur, prev;
      if (!(cur = this.getSelected())) return;
      prev = cur.prev();
      if (prev.length === 0) prev = this.$('li:last');
      cur.removeClass('selected');
      return prev.addClass('selected');
    };

    SearchView.prototype.oninputkeyup = function(e) {
      var txt;
      if (e.keyCode === 38) {
        this.selectPrev();
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
      if (e.keyCode === 40) {
        this.selectNext();
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
      txt = $.trim(this.input.val());
      if (txt.length > 3) {
        if (txt !== this.lastText) {
          this.lastText = txt;
          clearTimeout(this.searchTimer);
          return this.searchTimer = setTimeout(this.performSearch, 250);
        } else {
          return this.showSearchResults();
        }
      } else {
        return this.searchResults.hide();
      }
    };

    SearchView.prototype.extractAttributes = function(item) {
      var ret;
      ret = {
        thumbnail: item.thumbnail.sqDefault,
        title: item.title,
        viewCount: item.viewCount,
        uploader: item.uploader,
        url: item.url,
        videoId: item.id
      };
      return ret;
    };

    SearchView.prototype.showSearchResults = function() {
      var docHeight, srHeight, top;
      if (!this.collection.length) return;
      this.searchResults.show();
      top = this.searchResults.offset().top;
      docHeight = $(window).innerHeight();
      srHeight = Math.min(this.items.height(), docHeight - top - 10);
      return this.searchResults.height(srHeight);
    };

    SearchView.prototype.performSearch = function() {
      var txt, videoId,
        _this = this;
      txt = $.trim(this.input.val());
      if (!txt.length) return;
      this.collection.reset();
      if (utils.isYoutubeUrl(txt)) {
        videoId = utils.extractVideoId(txt);
        return $.getJSON('https://gdata.youtube.com/feeds/api/videos/' + videoId + '?v=2&alt=jsonc&callback=?', function(resp, textStatus) {
          if (textStatus === 'success') {
            _this.collection.reset([_this.extractAttributes(resp.data)]);
            return _this.showSearchResults();
          } else {
            console.log('Cannot get video info');
            return _this.searchResults.hide();
          }
        });
      } else {
        return $.getJSON('https://gdata.youtube.com/feeds/api/videos?q=' + txt + '&v=2&alt=jsonc&callback=?', function(resp, textStatus) {
          var item, items, nr, _ref2;
          if (textStatus === 'success' && (resp != null ? (_ref2 = resp.data) != null ? _ref2.totalItems : void 0 : void 0)) {
            nr = _.filter(resp.data.items, function(item) {
              return !item.restrictions;
            });
            items = (function() {
              var _i, _len, _ref3, _results;
              _ref3 = resp.data.items;
              _results = [];
              for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                item = _ref3[_i];
                _results.push(this.extractAttributes(item));
              }
              return _results;
            }).call(_this);
            _this.collection.reset(items);
            return _this.showSearchResults();
          } else {
            console.log('Nothing found');
            return _this.searchResults.hide();
          }
        });
      }
    };

    SearchView.prototype.addOne = function(item) {
      var view;
      view = new this.OneItemView({
        model: item
      });
      return this.items.append(view.render().el);
    };

    SearchView.prototype.addAll = function() {
      this.items.empty();
      return this.collection.each(this.addOne);
    };

    SearchView.prototype.render = function() {
      return this;
    };

    return SearchView;

  })(Backbone.View);

  exports.createView = function(el) {
    return new SearchView({
      el: el
    });
  };

}).call(this);
