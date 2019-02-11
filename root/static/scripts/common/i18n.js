/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from './i18n/expand2react';
import expand2text from './i18n/expand2text';
import * as wrapGettext from './i18n/wrapGettext';

export const l = wrapGettext.dgettext('mb_server');
export const ln = wrapGettext.dngettext('mb_server');
export const lp = wrapGettext.dpgettext('mb_server');

export const TEXT: {text: true} = Object.freeze({text: true});

type Nl = (string) => (
  & (() => string)
  & ((wrapGettext.ReactArgs) => AnyReactElem)
  & ((wrapGettext.TextArgs, typeof TEXT) => string)
);

type Nln = (string, string) => (
  & ((number) => string)
  & ((number, wrapGettext.ReactArgs) => AnyReactElem)
  & ((number, wrapGettext.TextArgs, typeof TEXT) => string)
);

type Nlp = (string, string) => (
  & (() => string)
  & ((wrapGettext.ReactArgs) => AnyReactElem)
  & ((wrapGettext.TextArgs, typeof TEXT) => string)
);

export const N_l: Nl = (((key) => (...args) => l(key, ...args)): any);
export const N_ln: Nln = (((skey, pkey) => (...args) => ln(skey, pkey, ...args)): any);
export const N_lp: Nlp = (((key, context) => (...args) => lp(key, context, ...args)): any);

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

export function addColon(variable: React$Node) {
  return l('{variable}:', {variable});
}

export function addColonText(variable: string) {
  return l('{variable}:', {variable}, TEXT);
}

export function hyphenateTitle(title: string, subtitle: string) {
  return l('{title} - {subtitle}', {subtitle, title}, TEXT);
}
