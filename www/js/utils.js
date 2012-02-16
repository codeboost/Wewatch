(function() {
  var unescapeString, _ref;

  if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.module) != null) _ref.enter('utils');
  }

  if (typeof _ !== "undefined" && _ !== null) {
    _.templateSettings = {
      escape: /\{\{(.+?)\}\}/g,
      interpolate: /\{\-\{(.+?)\}\}/g,
      evaluate: /\{\=\{(.+?)\}\}/g
    };
  }

  exports.loadTemplate = function(name) {
    name = name[0] === '#' ? name : '#' + name;
    return _.template($(name).html());
  };

  exports.unescapeString = unescapeString = function(text) {
    return $('<div/>').html(text).text();
  };

  exports.isYoutubeUrl = function(val) {
    return val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/);
  };

  exports.extractVideoId = function(url) {
    var _ref2;
    return (_ref2 = url.match(/v=(.{11})/)) != null ? _ref2[1] : void 0;
  };

  exports.extractItemAttributes = function(item) {
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

}).call(this);
