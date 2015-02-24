    

var websocket_connections = function(dispatcher){

    // var dispatcher = new WebSocketRails($("#socket_link").data('uri'), true);
    // var show_channel = new WebsocketClass(dispatcher);
    var stock_channel = new WebsocketClass(dispatcher);
    var stock_table_socket_binder = stock_table_socket.evt_binder("stocktable_ajax_handler");

    // var buy_sell_channel = new WebsocketClass(dispatcher);

    // var show_update_socket = new WebsocketClass(dispatcher);
    // var buy_sell_socket = new WebsocketClass(dispatcher);
    var stock_table_socket = new WebsocketClass(dispatcher);
    
    var close = function(fun){
         

    }

}

// var websocket_connections_close = function(){


// }