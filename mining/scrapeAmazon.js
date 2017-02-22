// Modify global object at the page initialization.
// In this example, effectively Math.random() always returns 0.42.

var link = 'https://www.amazon.com/dp/B016XVV2RY?psc=1';

"use strict";
var page = require('webpage').create();
page.settings.userAgent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36";
page.onConsoleMessage = function (msg) {
  console.log(msg);
}

var fs = require('fs');

page.open(link, function (status) {
  var result;
  if (status !== 'success') {
    console.log('Network error.', status);
  } else {
    console.log('success');

    // page.render('google.png');
    var result = page.evaluate(function (page) {

      var obj = {};
      var aI = document.getElementById('altImages');
      var images = aI.querySelectorAll('img');

      obj.images = [];

      for (var i = 0; i < images.length; i++) {
        obj.images.push(images[i].src);
      }
      console.log(document.title, page)

      return obj;

    });
    fs.write('testJSON.json', JSON.stringify(result), 'w');
  }
  localStorage.clear();
  phantom.exit();
});
