// @flow
// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

import isNodeJS from 'detect-node';

import cleanMsgid from './cleanMsgid';
import {type VarArgs} from './expand2';
import expand2react, {type Input} from './expand2react';
import expand2text from './expand2text';

import {type default as Jed} from 'jed';

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

export type ReactArgs = VarArgs<Input>;
export type TextArgs = VarArgs<StrOrNum>;

function _maybeExpand(result, args, flags) {
  return args ? (
    flags && flags.$text
      ? expand2text(result, args)
      : expand2react(result, args)
  ) : result;
}

export function dgettext(domain: Domain) {
  type F1 = (string) => string;
  type F2 = (string, args: ReactArgs) => React$Element<any>;
  type F3 = (string, args: TextArgs, {text: true}) => string;

  /*
   * Flow cannot infer that the function conforms to F1 & F2 & F3, so
   * we first must cast to `any`. See:
   * https://github.com/facebook/flow/issues/3021
   */
  return ((function (key, args, flags) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    key = cleanMsgid(key);
    return _maybeExpand(
      gettext.dgettext(domain, key),
      args,
      flags,
    );
  }: any): F1 & F2 & F3);
}

export function dngettext(domain: Domain) {
  type F1 = (string, string, number) => string;
  type F2 = (string, string, number, args: ReactArgs) => React$Element<any>;
  type F3 = (string, string, number, args: TextArgs, {text: true}) => string;

  return ((function (skey, pkey, val, args, flags) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    skey = cleanMsgid(skey);
    pkey = cleanMsgid(pkey);
    return _maybeExpand(
      gettext.dngettext(domain, skey, pkey, val),
      args,
      flags,
    );
  }: any): F1 & F2 & F3);
}

export function dpgettext(domain: Domain) {
  type F1 = (string, string) => string;
  type F2 = (string, string, args: ReactArgs) => React$Element<any>;
  type F3 = (string, string, args: TextArgs, {text: true}) => string;

  return ((function (key, context, args, flags) {
    if (canLoadDomain) {
      tryLoadDomain(domain);
    }
    key = cleanMsgid(key);
    return _maybeExpand(
      gettext.dpgettext(domain, context, key),
      args,
      flags,
    );
  }: any): F1 & F2 & F3);
}
