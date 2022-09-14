/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  l as lActual,
  ln as lnActual,
  lp as lpActual,
} from '../i18n.js';

import expand, {
  type VarArgsClass,
  type VarArgsObject,
  createCondSubstParser,
  createTextContentParser,
  parseContinuousString,
  parseStringVarSubst,
  state,
  VarArgs,
} from './expand2.js';

const textContent = /^[^{}]+/;
const condSubstThenTextContent = /^[^{}|]+/;

function handleTextContentText(text: string) {
  if (typeof state.replacement === 'string') {
    text = text.replace(/%/g, state.replacement);
  }
  return text;
}

const parseRootTextContent = createTextContentParser(
  textContent,
  handleTextContentText,
);

const parseCondSubst = createCondSubstParser<string, StrOrNum>(
  args => parseContinuousString<StrOrNum>(condSubstThenParsers, args),
  args => parseContinuousString<StrOrNum>(condSubstElseParsers, args),
);

const parseCondSubstThenTextContent = createTextContentParser(
  condSubstThenTextContent,
  handleTextContentText,
);

const condSubstThenParsers = [
  parseCondSubstThenTextContent,
  parseStringVarSubst,
  parseCondSubst,
];

const condSubstElseParsers = [
  parseRootTextContent,
  parseStringVarSubst,
  parseCondSubst,
];

const rootParsers = [
  parseRootTextContent,
  parseStringVarSubst,
  parseCondSubst,
];

function parseRoot(args: VarArgsClass<StrOrNum>) {
  return parseContinuousString<StrOrNum>(rootParsers, args);
}

/*
 * Like expand2react, but can only interpolate and produce plain text
 * values. To be more specific: HTML isn't parsed, link interpolation
 * syntax isn't supported, and only strings and numbers can be used
 * as var args. The result is always a string.
 *
 * This is useful in cases where strings are /required/, such as HTML
 * title or aria attributes and select option values. It can also be
 * used where plain text is expected (if not required), simply for the
 * stricter types.
 */
export default function expand2text(
  source: string,
  args: VarArgsObject<StrOrNum>,
): string {
  return expand2textWithVarArgsClass(source, new VarArgs(args));
}

export function expand2textWithVarArgsClass(
  source: string,
  args: VarArgsClass<StrOrNum>,
): string {
  return expand<string, StrOrNum>(parseRoot, source, args);
}

export const l = (
  key: string,
  args: VarArgsObject<StrOrNum>,
): string => expand2text(lActual(key), args);

export const ln = (
  skey: string,
  pkey: string,
  val: number,
  args: VarArgsObject<StrOrNum>,
): string => expand2text(lnActual(skey, pkey, val), args);

export const lp = (
  key: string,
  context: string,
  args: VarArgsObject<StrOrNum>,
): string => expand2text(lpActual(key, context), args);
