const parseCookie = require('cookie').parse;

const _cookies = require('./_cookies');

function getCookie(name, defaultValue = undefined) {
  let cookie;
  if (typeof $c !== 'undefined') {
    cookie = $c.req.headers.cookie;
  } else if (typeof document !== 'undefined') {
    cookie = document.cookie;
  } else {
    return _cookies.hasOwnProperty(name) ? _cookies[name] : defaultValue;
  }
  if (typeof cookie === 'string') {
    let values = parseCookie(cookie);
    if (values.hasOwnProperty(name)) {
      return values[name];
    }
  }
  return defaultValue;
}

module.exports = getCookie;
