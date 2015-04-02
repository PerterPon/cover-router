
"use strict";

function getCoffeeScriptVersion(){
  if ( require.extensions['.coffee'] ) {
    var coffee  = require( 'coffee-script' );
    var version = coffee.VERSION.split( '.' ).join( '' );
    return +version;
  } else {
    return 0;
  }
}

if ( require.extensions['.coffee'] && getCoffeeScriptVersion() >= 190 ) {
  require( 'coffee-script' ).register();
  module.exports = require( './lib/app.coffee' );
} else {
  module.exports = require( './out/lib/app.js' );
}
