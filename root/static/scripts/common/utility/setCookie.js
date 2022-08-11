import cookie from 'cookie';

import _cookies from './_cookies.js';

let defaultExport;

function oneYearFromNow() {
  return new Date(Date.now() + (1000 * 60 * 60 * 24 * 365));
}

function setCookieFallback(name, value) {
  _cookies[name] = value;
}

function setCookie(name, value, expiration = oneYearFromNow()) {
  document.cookie =
    cookie.serialize(name, value, {expires: expiration, path: '/'});
}

if (typeof document === 'undefined' ||
    window.location.protocol === 'file:') {
  defaultExport = setCookieFallback;
} else {
  defaultExport = setCookie;
}

export default defaultExport;
