// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const parseStack = require('parse-stack');

const request = require('./utility/request');

// https://wiki.musicbrainz.org/Development/Supported_browsers
var browser = $.browser;
var browserVersion = browser.version;
var browserIsSupported = (
  (browser.safari && browserVersion >= "5.1") ||
  (browser.chrome && browserVersion >= "31") ||
  (browser.msie && browserVersion >= "8.0") ||
  (browser.edge) ||
  (browser.mozilla && browserVersion >= "24") ||
  (browser.opera && browserVersion >= "12.10")
);

if (browserIsSupported) {
  let location = window.location;
  let origin = location.origin || (location.protocol + "//" + location.host);
  let urlRegex = new RegExp("^" + origin + "/static/build/.*\\.js$");
  let reported = {};

  window.onerror = function (message, url, line, column, error) {
    if (!urlRegex.test(url)) {
      return;
    }

    message += "\n\nURL: " + url + "\nLine: " + line;

    // Unavailable in Firefox<31 or Opera 12
    if (column !== undefined) {
      message += "\nColumn: " + column;
    }

    // Unavailable in IE<10 or Opera 12
    let stack;
    try {
      stack = parseStack(error);
    } catch (e) {
      // https://github.com/lydell/parse-stack/blob/3e1a2d3/lib/parse-stack.js#L46
    }

    if (stack) {
      // Check that the first (source) file in the stack originates from
      // root/static/build. This excludes errors from .js files that
      // userscripts inject into the page. The '.replace' removes line
      // numbers.
      let errOrigin = _.last(stack);
      if (errOrigin && errOrigin.filepath && !urlRegex.test(errOrigin.filepath.replace(/:\d+$/, ''))) {
        return;
      }

      message += "\n\n" + error.stack;
    }

    if (reported[message] === undefined) {
      reported[message] = true;

      request({
        type: "POST",
        url: "/ws/js/error",
        data: JSON.stringify({error: message}),
        contentType: "application/json; charset=utf-8"
      });
    }
  };
} else {
  let notice = "Unsupported browser detected: " + window.navigator.userAgent;
  if (window.console) {
    console.log(notice);
  } else if (window.opera) {
    opera.postError(notice);
  }
}
