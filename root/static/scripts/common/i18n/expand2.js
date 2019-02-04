/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import Raven from 'raven-js';
import * as React from 'react';
import ReactDOMServer from 'react-dom/server';

const NO_MATCH = Symbol();

const textContent = /^[^<>{}]+/;
const varSubst = /^\{([0-9A-z_]+)\}/;
const linkSubstStart = /^\{([0-9A-z_]+)\|/;
const condSubstStart = /^\{([0-9A-z_]+):/;
const condSubstThenTextContent = /^[^<>{}|]+/;
const substEnd = /^}/;
const htmlTagStart = /^<(?=[a-z])/;
const htmlTagName = /^(a|abbr|b|br|code|em|li|span|strong|ul)(?=[\s\/>])/;
const htmlTagEnd = /^>/;
const htmlSelfClosingTagEnd = /^\s*\/>/;
const htmlAttrStart = /^\s+(?=[a-z])/;
const htmlAttrName = /^(class|href|id|key|target|title)="/;
const htmlAttrTextContent = /^[^{}"]+/;
const percentSign = /(%)/;
const verticalPipe = /^\|/;
const hrefValueStart = /^(?:\/|https?:\/\/)/;

type VarArgs = {[string]: React.Node};

type State = {
  /*
   * Values to be substituted into the source string, passed as the
   * second argument to `expand`.
   */
  args: ?VarArgs,
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
  replacement: React.Node | typeof NO_MATCH,
  // A copy of the source string, used in error messages.
  source: string,
  /*
   * RegExp used by `parseTextContent` to parse text, which is anything
   * that isn't HTML or a substitution. The pattern varies in different
   * contexts due to symbols having different meanings inside
   * substitutions, HTML attributes, etc.
   */
  textPattern: RegExp,
};

const EMPTY_OBJECT = Object.freeze({});
const EMPTY_ARRAY = Object.freeze([]);

const state: State = Object.seal({
  args: EMPTY_OBJECT,
  match: '',
  position: 0,
  remainder: '',
  replacement: NO_MATCH,
  source: '',
  textPattern: textContent,
});

function hasArg(name) {
  return Object.prototype.hasOwnProperty.call(state.args, name);
}

function accept(pattern) {
  const m = state.remainder.match(pattern);
  if (m) {
    const entireMatch = m[0];
    state.match += entireMatch;
    state.position += entireMatch.length;
    state.remainder = state.remainder.slice(entireMatch.length);
    return m.length > 1 ? m[1] : entireMatch;
  }
  return NO_MATCH;
}

function error(message) {
  return new Error(
    `Failed to parse string ${JSON.stringify(state.source)} at position ` +
    `${state.position}: ${message}`
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
function saveMatch(cb) {
  return function () {
    const savedMatch = state.match;
    state.match = '';
    const result = cb.apply(null, arguments);
    state.match = savedMatch + state.match;
    return result;
  };
}

function pushChild<T>(
  children: Array<T>,
  match: T,
) {
  if (typeof match === 'number') {
    match = match.toString();
  }
  const size = children.length;
  if (size &&
      typeof match === 'string' &&
      typeof children[size - 1] === 'string') {
    // $FlowFixMe - Flow thinks the LHS can be a number here.
    children[size - 1] += match;
  } else {
    children.push(match);
  }
}

function parseContinous<T>(
  parsers: $ReadOnlyArray<() => T | typeof NO_MATCH>
): $ReadOnlyArray<T> {
  let children;
  let _continue = true;
  while (_continue) {
    _continue = false;
    for (let i = 0; i < parsers.length; i++) {
      const match = parsers[i]();
      if (match !== NO_MATCH) {
        if (!children) {
          children = [];
        }
        if (Array.isArray(match)) {
          for (let j = 0; j < match.length; j++) {
            pushChild<T>(children, match[j]);
          }
        } else {
          /*
            * XXX We need to convince Flow that `match` will always be
            * type T here, and not a Symbol.
            */
          pushChild<T>(children, ((match: any): T));
        }
        if (state.remainder) {
          _continue = true;
        } else {
          break;
        }
      }
    }
  }
  return children || EMPTY_ARRAY;
}

function parseTextContent() {
  let text = accept(state.textPattern);
  if (typeof text !== 'string') {
    return NO_MATCH;
  }
  if (state.replacement !== NO_MATCH && percentSign.test(text)) {
    const parts = text.split(percentSign);
    const result: Array<React.Node> = [];
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i];
      if (part === '%') {
        /* flow-include if (state.replacement instanceof Symbol) throw 'impossible' */
        result.push(state.replacement);
      } else {
        result.push(he.decode(part));
      }
    }
    return result;
  } else {
    text = he.decode(text);
  }
  return text;
}

/*
 * Sets `state.textPattern` while `cb` is executing, then returns it
 * back to its previous value. Used to parse text in different
 * contexts.
 */
function withTextPattern(textPattern, cb) {
  const savedTextPattern = state.textPattern;
  state.textPattern = textPattern;
  const result = cb();
  state.textPattern = savedTextPattern;
  return result;
}

const parseVarSubst = saveMatch(function () {
  const name = accept(varSubst);
  if (typeof name !== 'string') {
    return NO_MATCH;
  }
  if (state.args && hasArg(name)) {
    return state.args[name];
  }
  return state.match;
});

const parseLinkSubst = saveMatch(function () {
  const name = accept(linkSubstStart);
  if (typeof name !== 'string') {
    return NO_MATCH;
  }
  const children = withTextPattern(textContent, parseRoot);
  if (accept(substEnd) === NO_MATCH) {
    throw error('expected }');
  }
  if (state.args && hasArg(name)) {
    let props: any = state.args[name];
    if (typeof props === 'string') {
      props = {href: props};
    }
    return React.createElement('a', props, ...children);
  }
  return state.match;
});

const parseCondSubst = saveMatch(function () {
  const name = accept(condSubstStart);
  if (typeof name !== 'string') {
    return NO_MATCH;
  }

  const savedReplacement = state.replacement;
  if (state.args && hasArg(name)) {
    state.replacement = state.args[name];
  }

  const thenChildren = withTextPattern(condSubstThenTextContent, parseRoot);

  let elseChildren = '';
  if (accept(verticalPipe) !== NO_MATCH) {
    elseChildren = withTextPattern(textContent, parseRoot);
  }

  state.replacement = savedReplacement;

  if (accept(substEnd) === NO_MATCH) {
    throw error('expected }');
  }

  if (state.args && hasArg(name)) {
    const value = state.args[name];
    if (value) {
      return thenChildren;
    }
    return elseChildren;
  }
  return state.match;
});

const htmlAttrValueParsers = [
  parseTextContent,
  parseVarSubst,
  parseCondSubst,
];

function parseHtmlAttrValue() {
  return parseContinous(htmlAttrValueParsers);
}

function parseHtmlAttr() {
  if (accept(htmlAttrStart) === NO_MATCH) {
    return NO_MATCH;
  }

  let name = accept(htmlAttrName);
  if (typeof name !== 'string') {
    throw error('bad HTML attribute');
  }

  if (name === 'class') {
    name = 'className';
  }

  let value = withTextPattern(htmlAttrTextContent, parseHtmlAttrValue);

  if (accept(/^"/) === NO_MATCH) {
    throw error('expected "');
  }

  value = value.join('');

  if (name === 'href' && !hrefValueStart.test(value)) {
    throw error('bad href value');
  }

  return {[name]: value};
}

const htmlAttrParsers = [parseHtmlAttr];

function parseHtmlTag() {
  if (accept(htmlTagStart) === NO_MATCH) {
    return NO_MATCH;
  }

  const name = accept(htmlTagName);
  if (typeof name !== 'string') {
    throw error('bad HTML tag');
  }

  const attributes = parseContinous<{[string]: string}>(htmlAttrParsers);

  if (accept(htmlSelfClosingTagEnd) !== NO_MATCH) {
    // Self-closing tag
    return React.createElement(
      name,
      Object.assign.call(Object, {}, ...attributes),
    );
  }

  if (accept(htmlTagEnd) === NO_MATCH) {
    throw error('expected >');
  }

  const children = withTextPattern(textContent, parseRoot);

  if (accept(new RegExp('^</' + name + '>')) === NO_MATCH) {
    throw error('expected </' + name + '>');
  }

  return React.createElement(
    name,
    Object.assign.call(Object, {}, ...attributes),
    ...children,
  );
}

const rootParsers = [
  parseTextContent,
  parseVarSubst,
  parseLinkSubst,
  parseCondSubst,
  parseHtmlTag,
];

function parseRoot() {
  return parseContinous<React.Node>(rootParsers);
}

/*
 * `expand` takes a translated string and
 *  (1) interpolates values (React nodes) into it,
 *  (2) converts HTML to React elements.
 *
 * The output is intended for use with React, so the result is a valid
 * React node (a string, a React element, or null).
 *
 * A (safe) subset of HTML is supported, in addition to the variable
 * substitution syntax. In order to display a character reserved by
 * either syntax, HTML character entities must be used.
 */
export default function expand(source: ?string, args?: ?VarArgs): React.Node {
  if (!source) {
    return '';
  }

  // Reset the global state.
  state.args = args;
  state.match = '';
  state.position = 0;
  state.remainder = source;
  state.replacement = NO_MATCH;
  state.source = source;
  state.textPattern = textContent;

  let result;
  try {
    result = parseRoot();

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
    Raven.captureException(e);
    return source;
  } finally {
    // Remove reference to the args object, so it can be GC'd.
    state.args = EMPTY_OBJECT;
  }

  return result.length ? (
    result.length > 1
      ? React.createElement(React.Fragment, null, ...result)
      : result[0]
  ) : '';
}

export function expand2html(source: string, args: VarArgs) {
  return ReactDOMServer.renderToStaticMarkup(expand(source, args));
}
