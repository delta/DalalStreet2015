/*
 * restfulWebsockets.js
 * by Julian Borrey
 * Last Updated: 28/01/2014
 * Released under MIT license.
 *
 * Script to take a JSON object built by the restful_websockets_helper.rb
 * and refresh HTML elements in a REST-like manner.
 */

function RestfulWebsockets() {
   
   //execute this function with the JSON object you receive
   this.refresh = function(hash){
      if((hash != undefined) && (hash.htmlElts != undefined)){ //check for new html
         Object.keys(hash.htmlElts).forEach(function(key) { //for each html elt
            $(keyID(key)).replaceWith(hash.htmlElts[key]);  //completely replace
         });
      }
      return;
   }
   
   //makes an ID handle from input
   function keyID(keyStr){
      return ['#', keyStr].join('');
   }
   
}