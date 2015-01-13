var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

this.WebsocketClient = (function() {

  function WebsocketClient(wsURL) {
    this.wsURL = wsURL;
    
    this.handleSecrets = __bind(this.handleSecrets, this);

    this.bindChannel = __bind(this.bindChannel, this);

    this.authSuccess = __bind(this.authSuccess, this);

    this.reconnect = __bind(this.reconnect, this);

    this.bindEvents = __bind(this.bindEvents, this);

    this.onOpen = __bind(this.onOpen, this);

    this.setupDispatcher = __bind(this.setupDispatcher, this);

    this.running = false;
    
    this.setupDispatcher();
  }

  WebsocketClient.prototype.setupDispatcher = function() {
    this.connected = false;
    this.dispatcher = new WebSocketRails(this.wsURL);
    return this.dispatcher.on_open = this.onOpen;
  };

  WebsocketClient.prototype.onOpen = function() {
    this.connected = true;
    this.bindEvents();
    if (this.reconnectInterval) {
      return clearInterval(this.reconnectInterval);
    }
  };

  WebsocketClient.prototype.bindEvents = function() {
    this.dispatcher.bind('authenticated', this.authSuccess);
    return this.dispatcher.bind('connection_closed', this.reconnect);
  };

  WebsocketClient.prototype.reconnect = function() {
    this.reconnecting = true;
    return this.reconnectInterval = setInterval(this.setupDispatcher, 10000);
  };

  WebsocketClient.prototype.authSuccess = function(data) {
    this.secret_channel = this.dispatcher.subscribe(data.channel);
    return this.bindChannel();
  };

  WebsocketClient.prototype.bindChannel = function() {
    return this.secret_channel.bind('secret_message', this.handleSecrets);
  };

  WebsocketClient.prototype.handleSecrets = function(data) {
    return console.log('you get the idea');
  };

  return WebsocketClient;

})();