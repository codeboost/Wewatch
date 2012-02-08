// Generated by IcedCoffeeScript 1.2.0i
(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if ((_ref = window.module) != null) _ref.enter('ioState');

  exports.ConnectionState = (function(_super) {

    __extends(ConnectionState, _super);

    ConnectionState.name = 'ConnectionState';

    function ConnectionState() {
      return ConnectionState.__super__.constructor.apply(this, arguments);
    }

    ConnectionState.prototype.setState = function(state, msg) {
      return this.set({
        state: state,
        message: msg
      });
    };

    ConnectionState.prototype.join = function(sessionId) {
      var _this = this;
      this.setState('connecting');
      this.sio = io.connect();
      this.sio.socket.on('error', function(reason) {
        return _this.setState('error', reason);
      });
      this.sio.on('connect', function() {
        _this.setState('loading');
        return _this.sio.emit('join', sessionId, function(err, bootstrap) {
          if (err) return _this.setState('error', err);
          _this.setState('connected');
          return _this.trigger('joined', bootstrap);
        });
      });
      return this.sio.on('disconnect', function() {
        return _this.set({
          state: 'disconnected'
        });
      });
    };

    return ConnectionState;

  })(Backbone.Model);

}).call(this);
