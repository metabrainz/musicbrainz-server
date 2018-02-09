const parseCookie = require('cookie').parse;
const isNodeJS = require('detect-node');

const _cookies = require('./_cookies');

function getCookieFallback(name, defaultValue = undefined) {
  return _cookies.hasOwnProperty(name) ? _cookies[name] : defaultValue;
}

function getCookie(cookie, name, defaultValue) {
  if (typeof cookie === 'string') {
    let values = parseCookie(cookie);
    if (values.hasOwnProperty(name)) {
      return values[name];
    }
  }
  return defaultValue;
}

function getCookieBrowser(name, defaultValue = undefined) {
  return getCookie(document.cookie, name, defaultValue);
}

function getCookieServer(name, defaultValue = undefined) {
  const headers = $c.req.headers;
  const cookie = (
    headers.cookie ||
    headers.Cookie ||
    headers.COOKIE
  );
  return getCookie(cookie, name, defaultValue);
}

module.exports = getCookieFallback;

if (isNodeJS) {
  if (!process.env.MUSICBRAINZ_RUNNING_TESTS) {
    module.exports = getCookieServer;
  }
} else if (typeof document !== 'undefined' &&
           typeof window !== 'undefined' &&
           window.location.protocol !== 'file:') {
  module.exports = getCookieBrowser;
}
