(function() {
  var showError, utils;

  utils = require('utils');

  showError = function(msg) {
    var r;
    r = $('.err-message');
    $('.alert', r).text(msg);
    return r.removeClass('hidden');
  };

  ({
    hideError: function() {
      return $('.err-message').addClass('hidden');
    }
  });

  $(function() {
    var urlInput;
    urlInput = $('[name=url]');
    $('.you').submit(function(e) {
      var val, videoId;
      val = urlInput.val();
      if (!utils.isYoutubeUrl(val)) {
        showError("Not a valid youtube URL");
        e.preventDefault();
        false;
      }
      videoId = utils.extractVideoId(val);
      $.getJSON('https://gdata.youtube.com/feeds/api/videos/' + videoId + '?v=2&alt=jsonc&callback=?', function(resp, textStatus) {
        var item;
        if (textStatus === 'success' && !resp.error) {
          item = utils.extractItemAttributes(resp.data);
          item.url = val;
          return $.post('/createSession', item, function(resp, textStatus) {
            if (resp != null ? resp.sessionId : void 0) {
              return window.location = '/w/' + resp.sessionId;
            } else {
              return showError('Error fetching video details: ', resp.error);
            }
          });
        }
      });
      e.preventDefault();
      return false;
    });
    return urlInput.keyup(function() {
      var val;
      val = urlInput.val();
      if (utils.isYoutubeUrl(val)) return $('.err-message').addClass('hidden');
    });
  });

}).call(this);
