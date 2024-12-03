/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import cookie from 'cookie';

import _cookies from './_cookies.js';

function oneYearFromNow(): Date {
  return new Date(Date.now() + (1000 * 60 * 60 * 24 * 365));
}

function setCookie(
  name: string,
  value: StrOrNum | boolean,
  expiration: Date = oneYearFromNow(),
) {
  if (typeof document === 'undefined' ||
    window.location.protocol === 'file:') {
    _cookies[name] = value.toString();
  } else {
    document.cookie =
    cookie.serialize(
      name,
      value.toString(),
      {expires: expiration, path: '/'},
    );
  }
}

export default setCookie;
