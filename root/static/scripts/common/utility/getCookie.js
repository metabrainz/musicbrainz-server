/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isNodeJS from 'detect-node';

import _cookies from './_cookies.js';
import parseCookie from './parseCookie.mjs';

const HAS_DOCUMENT_COOKIE_ACCESS = !isNodeJS &&
                                   typeof document !== 'undefined' &&
                                   typeof window !== 'undefined' &&
                                   window.location.protocol !== 'file:';

function getCookie(name: string, defaultValue?: string = ''): string {
  if (HAS_DOCUMENT_COOKIE_ACCESS) {
    return parseCookie(document.cookie, name, defaultValue);
  }
  return Object.hasOwn(_cookies, name)
    ? _cookies[name]
    : defaultValue;
}

export default getCookie;
