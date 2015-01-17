var WebsocketClass = function(socket_url){

    var establish_conn = false;
    var binder = false;
    var evt = null;
    var channel_link = false;
    var dispatcher = null;
    var channel = null;

	var __connect = function(socket_url){
         dispatcher = new WebSocketRails($(socket_url).data('uri'), true);
         establish_conn = true;
	     console.log("Connection established : "+establish_conn);
	};

	this.__construct = function() {
         var connect = __connect(socket_url);
	}()


	this.callback = function(data){
         var rs = new RestfulWebsockets();
         console.log(data);
         rs.refresh(data);
	};

	this.evt_binder = function(evt){
         dispatcher.bind(evt, this.callback);
         binder = true;
	};

    this.bind_fail = function(){
         if(this.establish_conn)
         	this.evt_binder(evt);
         
    };
    
    this.failure = function(response){
         binder = false;
         console.log("failure: "+response.message);
    };    

    this.success = function(response){
         binder = true;
         console.log("success: "+response.message);
    }

	this.evt_trigger = function(evt,data){
         if(binder)
            dispatcher.trigger(evt, data, this.success, this.failure);
         else
            this.bind_fail(this.evt);            
	};

	this.evt_unbinder = function(){
	     // console.log(dispatcher);
         if(binder)
            {dispatcher.unbind(evt);
             binder = false;
	         console.log("Connection unbound : "+binder);
           }
	};

    this.channel_subscribe = function(channel_nm){
    	  if(establish_conn)
            { channel = dispatcher.subscribe(channel_nm);
              channel_link = true;
              console.log("Channel established :"+channel_link);
	        }
	      else
              console.log("Channel established :"+channel_link);
	};

	this.channel_binder = function(evt,callback_fn){
		if(channel_link)
          { // binder = true;
                channel.bind(evt, function(data){
                    console.log("data received :"+data);
                    callback_fn(data);
                });
          }
        else
          {
          	console.log("channel_link :"+channel_link);
          }  
	};

	this.channel_unbinder = function(evt){
        if(binder)
	      {channel.unbind(evt);
	       binder = false;
	       console.log("Channel unbound : "+binder);
	      }
    };

};