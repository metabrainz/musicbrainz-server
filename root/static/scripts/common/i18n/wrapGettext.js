// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

import isNodeJS from 'detect-node';

import cleanMsgid from './cleanMsgid';
import expand2 from './expand2';


let gettext;
if (isNodeJS) {
  gettext = require('../../../../server/gettext');
} else {
  const Jed = require('jed');
  const {jedData} = require('../../jed-data');
  // jedData contains all domains used by the client.
  gettext = new Jed(jedData[jedData.locale]);
}

const canLoadDomain = typeof gettext.loadDomain === 'function';

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
  if (canLoadDomain && !gettext.options.locale_data[domain]) {
    gettext.loadDomain(domain);
  }
}

export function dgettext(domain) {
  tryLoadDomain(domain);
  return function (key, args) {
    key = cleanMsgid(key);
    return expand2(gettext.dgettext(domain, key), args);
  };
}

export function dngettext(domain) {
  tryLoadDomain(domain);
  return function (skey, pkey, val, args) {
    skey = cleanMsgid(skey);
    pkey = cleanMsgid(pkey);
    return expand2(gettext.dngettext(domain, skey, pkey, val), args);
  };
}

export function dpgettext(domain) {
  tryLoadDomain(domain);
  return function (key, context, args) {
    key = cleanMsgid(key);
    return expand2(gettext.dpgettext(domain, context, key), args);
  };
}
