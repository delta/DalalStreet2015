var WebsocketClass = function(socket_url){

    var establish_conn = false;
    var binder = false;
    // var evt = null;
    var channel_link = false;
    var dispatcher = null;
    var channel = null;

	var __connect = function(socket_url){
         // dispatcher = new WebSocketRails($(socket_url).data('uri'), true);
         dispatcher = socket_url;
         establish_conn = true;
	     // console.log("Connection established : "+establish_conn);
	};

	this.__construct = function() {
         var connect = __connect(socket_url);
	}()

	this.callback = function(data){
         var rs = new RestfulWebsockets();
         console.log(data);
         $(".loader-div").replaceWith(" "); //make changes if necessary
         $(".loader-modal-div").replaceWith(" "); //make changes if necessary
         $("input").prop('disabled', false);
         rs.refresh(data);
	};

	this.evt_binder = function(evt){
         binder = true;
         // evt = evt;
        if(binder)
          dispatcher.bind(evt,this.callback);
        else
          console.log("Binder status : "+binder);
	};

    /// incomplete function for checking connection again....
    this.bind_fail = function(evt){
         if(establish_conn)
         	this.evt_binder(evt);
         else
            alert("Please refresh your page!");         
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
           {dispatcher.trigger(evt, data, this.success, this.failure);
            $(".loader-div").append("<div class=\"loader\"> <div></div> <div></div> <div></div> <div></div> <div></div> </div>");
            $(".loader-modal-div").append("<div class=\"loader\"> <div></div> <div></div> <div></div> <div></div> <div></div> </div>");
            $("input").prop('disabled', true);
           }         
         else
            this.bind_fail(evt);     
	};

	this.evt_unbinder = function(evt){    
         if(binder)
            {dispatcher.unbind(evt);
             binder = false;
	         console.log("binder status : "+binder);
            }
        else
           console.log("binder status : "+binder);
	};

    this.channel_subscribe = function(channel_nm){
    	  if(establish_conn)
            { channel = dispatcher.subscribe(channel_nm);
              channel_link = true;
              binder = true;
              console.log("Channel established :"+channel_link);
	        }
	      else
              console.log("Channel established :"+channel_link);
	};

	this.channel_binder = function(evt,callback_fn){
		if(channel_link)
        { 
          channel.bind(evt, function(data){ callback_fn(data); console.log("data received :"+data);});
          // channel.unbind(evt);
        }
        else
          	console.log("channel_link status:"+channel_link);
	};

	this.channel_unbinder = function(evt){
        if(binder)
	      {channel.unbind(evt);
	       binder = false;
	       console.log("Channel bound : "+binder);}
        else{
           console.log("Channel bound : "+binder);
         } 
    };

};