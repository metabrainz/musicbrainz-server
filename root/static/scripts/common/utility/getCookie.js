const parseCookie = require('cookie').parse;

const _cookies = require('./_cookies');

function getCookieFallback(name, defaultValue = undefined) {
  return _cookies.hasOwnProperty(name) ? _cookies[name] : defaultValue;
}

function getCookie(name, defaultValue = undefined) {
  let cookie;
  if (typeof $c !== 'undefined') {
    cookie = $c.req.headers.cookie;
  } else {
    cookie = document.cookie;
  }
  if (typeof cookie === 'string') {
    let values = parseCookie(cookie);
    if (values.hasOwnProperty(name)) {
      return values[name];
    }
  }
  return defaultValue;
}

if (typeof document === 'undefined' ||
    window.location.protocol === 'file:') {
  module.exports = getCookieFallback;
} else {
  module.exports = getCookie;
}
