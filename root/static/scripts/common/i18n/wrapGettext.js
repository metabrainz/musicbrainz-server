/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isNodeJS from 'detect-node';
import Jed from 'jed';

import * as serverGettext from '../../../../server/gettext.mjs';
import jedData from '../../jed-data.mjs';

import cleanMsgid from './cleanMsgid.js';

let gettext;
if (isNodeJS) {
  gettext = serverGettext;
} else {
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

function tryLoadDomain(domain: GettextDomainT) {
  const jedInstance = serverGettext.jedInstance;
  if (
    jedInstance != null &&
    !jedInstance.options.locale_data[domain]
  ) {
    serverGettext.loadDomain(domain);
  }
}

type GettextDomainT =
  | 'attributes'
  | 'countries'
  | 'instrument_descriptions'
  | 'instruments'
  | 'languages'
  | 'mb_server'
  | 'relationships'
  | 'scripts'
  | 'statistics';

export function dgettext(domain: GettextDomainT): ((string) => string) {
  return function (key: string) {
    tryLoadDomain(domain);
    const cleanedKey = cleanMsgid(key);
    return gettext.dgettext(domain, cleanedKey);
  };
}

export function dngettext(
  domain: GettextDomainT,
): ((string, string, number) => string) {
  return function (skey: string, pkey: string, val: number) {
    tryLoadDomain(domain);
    const cleanedSKey = cleanMsgid(skey);
    const cleanedPKey = cleanMsgid(pkey);
    return gettext.dngettext(domain, cleanedSKey, cleanedPKey, val);
  };
}

export function dpgettext(
  domain: GettextDomainT,
): ((string, string) => string) {
  return function (key: string, context: string) {
    tryLoadDomain(domain);
    const cleanedKey = cleanMsgid(key);
    return gettext.dpgettext(domain, context, cleanedKey);
  };
}
