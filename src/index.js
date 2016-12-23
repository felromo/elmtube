'use strict';

require('./index.html');
var YTSearch = require ('youtube-api-search');
var Elm = require('./Main');

var elm = Elm.Main.fullscreen();



//interop
// elm.ports.alert.subscribe(function(message) {
//   alert(message);
//   elm.ports.log.send('Alert called: ' + message);
// });

//elm-hot callback
// elm.hot.subscribe(function (event, context) {
//   console.log('elm-hot event:', event)
//   context.state.swapCount ++
// })

const API_KEY = 'AIzaSyAVYprfgQ03PuwwwKLNVdh6KJr2Me9XLYM';

elm.ports.searchQuery.subscribe(function (query) {
    // console.log('Come from elm', query);
    YTSearch({key: API_KEY, term: query}, videos => {
        console.log(videos);
    });
});
