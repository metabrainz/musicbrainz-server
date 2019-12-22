import isNodeJS from 'detect-node';

import parseCookie from './parseCookie';
import _cookies from './_cookies';

let defaultExport = getCookieFallback;

function getCookieFallback(name, defaultValue = undefined) {
  let cookieHasName = Object.prototype.hasOwnProperty.call(_cookies, name);
  return cookieHasName ? _cookies[name] : defaultValue;
}

function getCookieBrowser(name, defaultValue = undefined) {
  return parseCookie(document.cookie, name, defaultValue);
}

if (!isNodeJS &&
    typeof document !== 'undefined' &&
    typeof window !== 'undefined' &&
    window.location.protocol !== 'file:') {
  defaultExport = getCookieBrowser;
}

export default defaultExport;
