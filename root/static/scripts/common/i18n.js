/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './i18n/wrapGettext.js';

export const l: (string) => string =
  wrapGettext.dgettext('mb_server');

export const ln: (string, string, number) => string =
  wrapGettext.dngettext('mb_server');

export const lp: (string, string) => string =
  wrapGettext.dpgettext('mb_server');

export const N_l = (key: string): (() => string) => (
  () => l(key)
);
export const N_ln = (skey: string, pkey: string): ((number) => string) => (
  (val: number) => ln(skey, pkey, val)
);
export const N_lp = (key: string, context: string): (() => string) => (
  () => lp(key, context)
);

export const unwrapNl = <T: Expand2ReactOutput>(
  value: T | (() => T),
): T => (
    typeof value === 'function' ? value() : value
  );

let documentLang = 'en';
if (typeof document !== 'undefined') {
  const documentElement = document.documentElement;
  if (documentElement) {
    documentLang = documentElement.lang || documentLang;
  }
}

const collatorOptions = {numeric: true};

const collator = typeof Intl === 'undefined'
  ? null
  : new Intl.Collator(documentLang, collatorOptions);

export function compare(a: string, b: string): number {
  if (collator) {
    return collator.compare(a, b);
  }
  return a.localeCompare(b, documentLang, collatorOptions);
}
