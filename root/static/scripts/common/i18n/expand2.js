/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as Sentry from '@sentry/browser';

/*
 * Flow doesn't have very good support for Symbols, so we use a unique
 * singleton class to fill its role.
 */
export class NO_MATCH {
  static instance: ?NO_MATCH;

  constructor(): NO_MATCH {
    return NO_MATCH.instance || (NO_MATCH.instance = this);
  }
}

export const NO_MATCH_VALUE: NO_MATCH = new NO_MATCH();
Object.freeze(NO_MATCH);

export function gotMatch(x: mixed): boolean %checks {
  return (
    x !== NO_MATCH_VALUE /* flow-include && !(x instanceof NO_MATCH) */
  );
}

export type VarArgsObject<+T> = {
  +[arg: string]: T,
};

export interface VarArgsClass<+T> {
  get(name: string): T,
  has(name: string): boolean,
}

export class VarArgs<+T, +U = T> implements VarArgsClass<T | U> {
  +data: VarArgsObject<T>;

  constructor(data: VarArgsObject<T>) {
    this.data = data;
  }

  get(name: string): T | U {
    return this.data[name];
  }

  has(name: string): boolean {
    return hasOwnProp(this.data, name);
  }
}

export type Parser<+T, -V> = (VarArgsClass<V>) => T;

const EMPTY_OBJECT = Object.freeze({});
const EMPTY_VARARGS = new VarArgs(EMPTY_OBJECT);

type State = {
  /*
   * A slice of the source string containing an in-progress match; used
   * as a fallback if there's no substitution value in `args`.
   */
  match: string,
  // Current parser position in the source string.
  position: number,
  // Portion of the source string that hasn't been parsed yet.
  remainder: string,
  // The value of % in conditional substitutions, from `args`.
  replacement: string | React$MixedElement | NO_MATCH,
  // Whether expand is currently running. Used to detect nested calls.
  running: boolean,
  // A copy of the source string, used in error messages.
  source: string,
};

export const state: State = Object.seal({
  match: '',
  position: 0,
  remainder: '',
  replacement: NO_MATCH_VALUE,
  running: false,
  source: '',
});

export function getString(x: mixed): string {
  if (typeof x === 'string') {
    return x;
  }
  if (typeof x === 'number') {
    return String(x);
  }
  return '';
}

export function getVarSubstArg(x: mixed): React$MixedElement | string {
  if (React.isValidElement(x)) {
    return ((x: any): React$MixedElement);
  }
  return getString(x);
}

export function accept(pattern: RegExp): NO_MATCH | string {
  const m = state.remainder.match(pattern);
  if (m) {
    const entireMatch = m[0];
    state.match += entireMatch;
    state.position += entireMatch.length;
    state.remainder = state.remainder.slice(entireMatch.length);
    return m.length > 1 ? m[1] : entireMatch;
  }
  return NO_MATCH_VALUE;
}

export function error(message: string): Error {
  return new Error(
    `Failed to parse string ${JSON.stringify(state.source)} at position ` +
    `${state.position}: ${message}`,
  );
}

/*
 * Resets the current `match` variable while `cb` is executing. This is
 * used by the substitution parsers. If we parse "{foo|{bar}}", for
 * example, `state.match` will be "{bar}" for the inner substitution
 * and "{foo|{bar}}" for the outer one. This allows us to return
 * `state.match` if there's no `foo` or `bar` variable in `args`, thus
 * performing no substitution in that case.
 */
export function saveMatch<T, V>(cb: Parser<T, V>): Parser<T, V> {
  return function (args) {
    const savedMatch = state.match;
    state.match = '';
    const result = cb(args);
    state.match = savedMatch + state.match;
    return result;
  };
}

export function parseContinuous<T, U, V>(
  parsers: $ReadOnlyArray<Parser<T | NO_MATCH, V>>,
  args: VarArgsClass<V>,
  matchCallback: (U | NO_MATCH, T) => U,
  defaultValue: U,
): U {
  let children: U | NO_MATCH = NO_MATCH_VALUE;
  let _continue = true;
  while (_continue) {
    _continue = false;
    for (let i = 0; i < parsers.length; i++) {
      const match = parsers[i](args);
      if (gotMatch(match)) {
        children = matchCallback(children, match);
        if (state.remainder) {
          _continue = true;
        } else {
          break;
        }
      }
    }
  }
  if (!gotMatch(children)) {
    return defaultValue;
  }
  return children;
}

function concatStringMatch(
  accum: string | NO_MATCH,
  match: string | NO_MATCH,
): string {
  return (
    (gotMatch(accum) ? accum : '') +
    (gotMatch(match) ? match : '')
  );
}

export function parseContinuousString<V>(
  parsers: $ReadOnlyArray<Parser<string | NO_MATCH, V>>,
  args: VarArgsClass<V>,
): string {
  return parseContinuous<string, string, V>(
    parsers,
    args,
    concatStringMatch,
    '',
  );
}

export const createTextContentParser = <+T, V>(
  textPattern: RegExp,
  mapValue: (string) => T,
): Parser<T | string | NO_MATCH, V> => () => {
  const text = accept(textPattern);
  if (typeof text !== 'string') {
    return NO_MATCH_VALUE;
  }
  return mapValue(text);
};

const varSubst = /^\{([0-9A-z_]+)\}/;
export const createVarSubstParser = <T, V>(
  argFilter: (V) => T,
): Parser<T | string | NO_MATCH, V> => saveMatch(
  function (args: VarArgsClass<V>) {
    const name = accept(varSubst);
    if (typeof name !== 'string') {
      return NO_MATCH_VALUE;
    }
    if (args.has(name)) {
      return argFilter(args.get(name));
    }
    return state.match;
  },
);

export const parseStringVarSubst: Parser<string | NO_MATCH, mixed> =
  createVarSubstParser<string, mixed>(getString);

const condSubstStart = /^\{([0-9A-z_]+):/;
const verticalPipe = /^\|/;
export const substEnd: RegExp = /^}/;
export const createCondSubstParser = <T, V>(
  thenParser: Parser<T, V>,
  elseParser: Parser<T, V>,
): Parser<T | string | NO_MATCH, V> => saveMatch(function (args) {
  const name = accept(condSubstStart);
  if (typeof name !== 'string') {
    return NO_MATCH_VALUE;
  }

  const savedReplacement = state.replacement;
  if (args.has(name)) {
    state.replacement = getVarSubstArg(args.get(name));
  }

  const thenChildren = thenParser(args);

  let elseChildren: T | string = '';
  if (gotMatch(accept(verticalPipe))) {
    elseChildren = elseParser(args);
  }

  state.replacement = savedReplacement;

  if (!gotMatch(accept(substEnd))) {
    throw error('expected }');
  }

  if (args.has(name)) {
    const value = args.get(name);
    if (value) {
      return thenChildren;
    }
    return elseChildren;
  }
  return state.match;
});

/*
 * This is not meant to be called directly, except by expand2react and
 * expand2text. These functions accept an args hash containing values
 * of type V, and produce an expansion result of type T.
 *
 * So in the case of expand2react, the types would be:
 * expand<string | React.Element<any>, string | number | React.Element<any>>;
 *
 * And for expand2text they'd be:
 * expand<string, string | number>;
 *
 * Thus these signatures provide type safety on both the return value
 * and input arg values.
 */
export default function expand<+T, V>(
  rootParser: (VarArgsClass<V>) => T,
  source: ?string,
  args: ?VarArgsClass<V>,
): T | string {
  if (!source) {
    return '';
  }

  let savedState;
  if (state.running) {
    savedState = {...state};
  }

  // Reset the global state.
  state.match = '';
  state.position = 0;
  state.remainder = source;
  state.replacement = NO_MATCH_VALUE;
  state.running = true;
  state.source = source;

  let result;
  try {
    result = rootParser(args ?? EMPTY_VARARGS);

    if (state.remainder) {
      throw error('unexpected token');
    }
  } catch (e) {
    /*
     * If we can't parse the string, just return the source string back
     * so that the page doesn't break. But also log the error to the
     * console and Sentry.
     */
    console.error(e);
    Sentry.captureException(e);
    return source;
  } finally {
    if (savedState) {
      Object.assign(state, savedState);
    } else {
      state.running = false;
    }
  }

  return result;
}
