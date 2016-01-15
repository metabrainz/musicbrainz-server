const parseCookie = require('cookie').parse;

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

module.exports = getCookie;
