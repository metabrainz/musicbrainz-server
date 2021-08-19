/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isNodeJS from 'detect-node';

import parseCookie from './parseCookie';
import _cookies from './_cookies';

let defaultExport: (name: string, defaultValue?: string) => string =
  getCookieFallback;

function getCookieFallback(name: string, defaultValue?: string = '') {
  return hasOwnProp(_cookies, name)
    ? _cookies[name]
    : defaultValue;
}

function getCookieBrowser(name: string, defaultValue?: string = '') {
  return parseCookie(document.cookie, name, defaultValue);
}

if (!isNodeJS &&
    typeof document !== 'undefined' &&
    typeof window !== 'undefined' &&
    window.location.protocol !== 'file:') {
  defaultExport = getCookieBrowser;
}

export default defaultExport;
