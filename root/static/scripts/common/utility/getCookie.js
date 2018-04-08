const isNodeJS = require('detect-node');

import parseCookie from './parseCookie';
const _cookies = require('./_cookies');

function getCookieFallback(name, defaultValue = undefined) {
  return _cookies.hasOwnProperty(name) ? _cookies[name] : defaultValue;
}

function getCookieBrowser(name, defaultValue = undefined) {
  return parseCookie(document.cookie, name, defaultValue);
}

module.exports = getCookieFallback;

if (!isNodeJS &&
    typeof document !== 'undefined' &&
    typeof window !== 'undefined' &&
    window.location.protocol !== 'file:') {
  module.exports = getCookieBrowser;
}
