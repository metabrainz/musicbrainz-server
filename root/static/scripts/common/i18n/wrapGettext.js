// @flow
// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

import isNodeJS from 'detect-node';
import {type default as Jed} from 'jed';

import cleanMsgid from './cleanMsgid';


let gettext: Jed;
if (isNodeJS) {
  gettext = require('../../../../server/gettext');
} else {
  const Jed = require('jed');
  const {jedData} = require('../../jed-data');
  // jedData contains all domains used by the client.
  gettext = new Jed(jedData[jedData.locale]);
}

const canLoadDomain = typeof (gettext: any).loadDomain === 'function';

/*
 * On the usage of cleanMsgid:
 *
 * /script/xgettext.js will strip newlines and collapse adjacent
 * whitespace when extracting strings into .pot files. Yet the string
 * in the source code obviously remains unchanged. So to make sure we
 * look up the correct key, we have to apply the same whitespace
 * transformation here.
 */

type Domain =
  | 'attributes'
  | 'countries'
  | 'instrument_descriptions'
  | 'instruments'
  | 'languages'
  | 'mb_server'
  | 'relationships'
  | 'scripts'
  | 'statistics'
  ;

function tryLoadDomain(domain) {
  if (!gettext.options.locale_data[domain]) {
    (gettext: any).loadDomain(domain);
  }
}

export function dgettext(domain: Domain) {
  return function (key: string) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    key = cleanMsgid(key);
    return gettext.dgettext(domain, key);
  };
}

export function dngettext(domain: Domain) {
  return function (skey: string, pkey: string, val: number) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    skey = cleanMsgid(skey);
    pkey = cleanMsgid(pkey);
    return gettext.dngettext(domain, skey, pkey, val);
  };
}

export function dpgettext(domain: Domain) {
  return function (key: string, context: string) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    key = cleanMsgid(key);
    return gettext.dpgettext(domain, context, key);
  };
}
