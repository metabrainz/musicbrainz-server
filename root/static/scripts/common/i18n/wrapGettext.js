/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isNodeJS from 'detect-node';
import Jed from 'jed';

import cleanMsgid from './cleanMsgid';

let gettext;
let serverGettext;
if (isNodeJS) {
  gettext = require('../../../../server/gettext');
  serverGettext = gettext;
} else {
  const jedData = require('../../jed-data');
  // jedData contains all domains used by the client.
  gettext = new Jed(jedData[jedData.locale]);
}

/*
 * On the usage of cleanMsgid:
 *
 * /script/xgettext.js will strip newlines and collapse adjacent
 * whitespace when extracting strings into .pot files. Yet the string
 * in the source code obviously remains unchanged. So to make sure we
 * look up the correct key, we have to apply the same whitespace
 * transformation here.
 */

function tryLoadDomain(domain) {
  if (serverGettext &&
      !serverGettext.jedInstance.options.locale_data[domain]) {
    serverGettext.loadDomain(domain);
  }
}

export function dgettext(domain: GettextDomain) {
  return function (key: string) {
    tryLoadDomain(domain);
    key = cleanMsgid(key);
    return gettext.dgettext(domain, key);
  };
}

export function dngettext(domain: GettextDomain) {
  return function (skey: string, pkey: string, val: number) {
    tryLoadDomain(domain);
    skey = cleanMsgid(skey);
    pkey = cleanMsgid(pkey);
    return gettext.dngettext(domain, skey, pkey, val);
  };
}

export function dpgettext(domain: GettextDomain) {
  return function (key: string, context: string) {
    tryLoadDomain(domain);
    key = cleanMsgid(key);
    return gettext.dpgettext(domain, context, key);
  };
}
