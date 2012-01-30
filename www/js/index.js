(function() {

  $(function() {
    var urlInput;
    urlInput = $('[name=url]');
    $('.you').submit(function(e) {
      var val;
      val = urlInput.val();
      if (!val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/)) {
        $('.err-message').removeClass('hidden');
        e.preventDefault();
        return false;
      }
    });
    return urlInput.keyup(function() {
      var val;
      val = urlInput.val();
      if (val.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=(.{11}))/)) {
        return $('.err-message').addClass('hidden');
      }
    });
  });

}).call(this);
