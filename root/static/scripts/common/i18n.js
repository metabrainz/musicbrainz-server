/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './i18n/wrapGettext';

export const l = wrapGettext.dgettext('mb_server');
export const ln = wrapGettext.dngettext('mb_server');
export const lp = wrapGettext.dpgettext('mb_server');

export const N_l = (key: string) => (
  () => l(key)
);
export const N_ln = (skey: string, pkey: string) => (
  (val: number) => ln(skey, pkey, val)
);
export const N_lp = (key: string, context: string) => (
  () => lp(key, context)
);

export const unwrapNl = (value: string | () => string) => (
  typeof value === 'string' ? value : value()
);

let documentLang = 'en';
if (typeof document !== 'undefined') {
  const documentElement = document.documentElement;
  if (documentElement) {
    documentLang = documentElement.lang || documentLang;
  }
}

const collatorOptions = {numeric: true};

let compare;
if (typeof Intl === 'undefined') {
  compare = function (a: string, b: string) {
    return a.localeCompare(b, documentLang, collatorOptions);
  };
} else {
  const collator = new Intl.Collator(documentLang, collatorOptions);
  compare = function (a: string, b: string) {
    return collator.compare(a, b);
  };
}
export {compare};
