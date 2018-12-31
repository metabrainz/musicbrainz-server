/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import NopArgs from './i18n/NopArgs';
import wrapGettext from './i18n/wrapGettext';

export const l = wrapGettext('dgettext', 'mb_server');
export const ln = wrapGettext('dngettext', 'mb_server');
export const lp = wrapGettext('dpgettext', 'mb_server');

function noop(func) {
  return (...args) => new NopArgs(func, args);
}

export const N_l = noop(l);
export const N_ln = noop(ln);
export const N_lp = noop(lp);

let documentLang = 'en';
if (typeof document !== 'undefined') {
  documentLang = document.documentElement.lang || documentLang;
}

const collatorOptions = {numeric: true};

export let compare;
if (typeof Intl === 'undefined') {
  compare = function (a, b) {
    return a.localeCompare(b, documentLang, collatorOptions);
  };
} else {
  const collator = new Intl.Collator(documentLang, collatorOptions);
  compare = function (a, b) {
    return collator.compare(a, b);
  };
}

export function addColon(variable) {
  return l('{variable}:', {variable});
}

export function hyphenateTitle(title, subtitle) {
  return l('{title} - {subtitle}', {subtitle, title});
}
