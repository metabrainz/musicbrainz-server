/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';

import {
  l as lActual,
  ln as lnActual,
  lp as lpActual,
} from '../i18n.js';

import expand, {
  type NO_MATCH,
  type Parser,
  type VarArgsClass,
  type VarArgsObject,
  accept,
  createCondSubstParser,
  createTextContentParser,
  createVarSubstParser,
  error,
  getVarSubstArg,
  gotMatch,
  NO_MATCH_VALUE,
  parseContinuous,
  parseContinuousString,
  parseStringVarSubst,
  saveMatch,
  state,
  substEnd,
  VarArgs,
} from './expand2.js';

type Input = Expand2ReactInput;
type Output = Expand2ReactOutput;

const textContent = /^[^<>{}]+/;
const condSubstThenTextContent = /^[^<>{}|]+/;
const percentSign = /(%)/;
const linkSubstStart = /^\{([0-9A-z_]+)\|/;
const htmlTagStart = /^<(?=[a-z])/;
const htmlTagName = /^(a|abbr|br|code|em|h1|h2|h3|h4|h5|h6|hr|li|ol|p|span|strong|ul)(?=[\s\/>])/;
const htmlTagEnd = /^>/;
const htmlSelfClosingTagEnd = /^\s*\/>/;
const htmlAttrStart = /^\s+(?=[a-z])/;
const htmlAttrName = /^(class|href|id|key|rel|target|title)="/;
const htmlAttrTextContent = /^[^{}"]+/;
const hrefValueStart = /^(?:\/|https?:\/\/|ircs?:\/\/)/;

function handleTextContentText(text: string) {
  let handledText = text;
  if (typeof state.replacement === 'string') {
    handledText = text.replace(/%/g, he.encode(state.replacement));
  }
  return he.decode(handledText);
}

/*
 * `reactTextContentHook`, when overridden from the outside, allows
 * customizing each bit of free text content in the expanded string. This can
 * be used, for example, to wrap them in spans to apply a certain style.
 * (This is how our relationship edit diff display works.)
 *
 * The use of the word "hooks" here is completely unrelated to the React
 * concept with the same name.
 */
export const hooks: {
  reactTextContentHook: ((Expand2ReactOutput) => Expand2ReactOutput) | null,
} = {
  reactTextContentHook: null,
};

function handleTextContentReact(text: string) {
  const replacement = state.replacement;
  const hook = hooks.reactTextContentHook;
  let content;

  if (gotMatch(replacement) && percentSign.test(text)) {
    const parts = text.split(percentSign);
    const result: Array<Output> = [];
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i];
      if (part === '%') {
        result.push(replacement);
      } else {
        result.push(he.decode(part));
      }
    }
    if (typeof replacement === 'string') {
      content = result.join('');
    } else {
      content = React.createElement(React.Fragment, null, ...result);
    }
  } else {
    content = he.decode(text);
  }

  return hook ? hook(content) : content;
}

const parseRootTextContent = createTextContentParser<Output, Input>(
  textContent,
  handleTextContentReact,
);

const parseVarSubst = createVarSubstParser<Output, Input>(
  getVarSubstArg,
);

const parseLinkSubst = saveMatch<
  React.Element<'a'> | string | NO_MATCH,
  Input,
>(function (args) {
  const name = accept(linkSubstStart);
  if (typeof name !== 'string') {
    return NO_MATCH_VALUE;
  }
  const children = parseRoot(args);
  if (!gotMatch(accept(substEnd))) {
    throw error('expected }');
  }
  if (args.has(name)) {
    let props = args.get(name);
    if (typeof props === 'string') {
      props = ({href: props}: AnchorProps);
    }
    if (!props || typeof props === 'number' || empty(props.href)) {
      throw error('bad link props');
    }
    return React.createElement('a', props, ...children);
  }
  return state.match;
});

function pushChild<T>(
  children: Array<T>,
  match: T,
): Array<T> {
  const lastIndex = children.length - 1;
  if (lastIndex >= 0 &&
      typeof match === 'string' &&
      typeof children[lastIndex] === 'string') {
    // $FlowIssue[incompatible-type]
    children[lastIndex] += match;
  } else {
    children.push(match);
  }
  return children;
}

/*
 * `MatchUpperBoundT` is used as the upper bound of `T` below, meaning
 * `T` can be any subtype of `MatchUpperBoundT`. Generally parsers will
 * produce strings/numbers, but they can also output React elements and
 * other object types, so `{...}` must be included too.
 */
type MatchUpperBoundT = StrOrNum | {...};

function concatArrayMatch<T: MatchUpperBoundT>(
  children: Array<T> | NO_MATCH,
  match: Array<T> | T,
): Array<T> {
  let matchedChildren = children;
  if (!gotMatch(matchedChildren)) {
    matchedChildren = [];
  }
  if (Array.isArray(match)) {
    for (let j = 0; j < match.length; j++) {
      pushChild(matchedChildren, match[j]);
    }
  } else {
    pushChild(matchedChildren, match);
  }
  return matchedChildren;
}

function parseContinuousArray<T: MatchUpperBoundT, V>(
  parsers: $ReadOnlyArray<Parser<Array<T> | T | NO_MATCH, V>>,
  args: VarArgsClass<V>,
): Array<T> {
  return parseContinuous<Array<T> | T, Array<T>, V>(
    parsers,
    args,
    concatArrayMatch,
    [],
  );
}

const parseHtmlAttrValue = (args: VarArgsClass<Input>) => (
  parseContinuousString(htmlAttrValueParsers, args)
);

const parseHtmlAttrValueCondSubst =
  createCondSubstParser<string, Input>(
    args => parseContinuousString(htmlAttrCondSubstThenParsers, args),
    args => parseContinuousString(htmlAttrCondSubstElseParsers, args),
  );

const htmlAttrCondSubstThenParsers = [
  createTextContentParser<string, Input>(
    condSubstThenTextContent,
    handleTextContentText,
  ),
  parseStringVarSubst,
  parseHtmlAttrValueCondSubst,
];

const htmlAttrCondSubstElseParsers = [
  createTextContentParser<string, Input>(
    textContent,
    handleTextContentText,
  ),
  parseStringVarSubst,
  parseHtmlAttrValueCondSubst,
];

const htmlAttrValueParsers = [
  createTextContentParser<string, Input>(
    htmlAttrTextContent,
    handleTextContentText,
  ),
  parseStringVarSubst,
  parseHtmlAttrValueCondSubst,
];

type HtmlAttrs = {[attr: string]: string};

function parseHtmlAttr(args: VarArgsClass<Input>) {
  if (!gotMatch(accept(htmlAttrStart))) {
    return NO_MATCH_VALUE;
  }

  let name = accept(htmlAttrName);
  if (typeof name !== 'string') {
    throw error('bad HTML attribute');
  }

  if (name === 'class') {
    name = 'className';
  }

  const value = parseHtmlAttrValue(args);

  if (!gotMatch(accept(/^"/))) {
    throw error('expected "');
  }

  if (name === 'href' && !hrefValueStart.test(value)) {
    throw error('bad href value');
  }

  /*
   * See "Flow errors on unions in computed properties" here:
   * https://medium.com/flow-type/spreads-common-errors-fixes-9701012e9d58
   */
  const attr: HtmlAttrs = {};
  attr[name] = value;
  return attr;
}

const htmlAttrParsers = [parseHtmlAttr];

function parseHtmlTag(args: VarArgsClass<Input>) {
  if (!gotMatch(accept(htmlTagStart))) {
    return NO_MATCH_VALUE;
  }

  const name = accept(htmlTagName);
  if (typeof name !== 'string') {
    throw error('bad HTML tag');
  }

  const attributes = parseContinuousArray<HtmlAttrs, Input>(
    htmlAttrParsers,
    args,
  );

  if (gotMatch(accept(htmlSelfClosingTagEnd))) {
    // Self-closing tag
    return React.createElement(
      name,
      Object.assign(({}: HtmlAttrs), ...attributes),
    );
  }

  if (!gotMatch(accept(htmlTagEnd))) {
    throw error('expected >');
  }

  const children = parseRoot(args);

  if (!gotMatch(accept(new RegExp('^</' + name + '>')))) {
    throw error('expected </' + name + '>');
  }

  return React.createElement(
    name,
    Object.assign(({}: HtmlAttrs), ...attributes),
    ...children,
  );
}

const parseCondSubst = createCondSubstParser<Array<Output>, Input>(
  args => parseContinuousArray(condSubstThenParsers, args),
  args => parseContinuousArray(condSubstElseParsers, args),
);

const condSubstThenParsers = [
  createTextContentParser<Output, Input>(
    condSubstThenTextContent,
    handleTextContentReact,
  ),
  parseVarSubst,
  parseLinkSubst,
  parseCondSubst,
  parseHtmlTag,
];

const condSubstElseParsers = [
  parseRootTextContent,
  parseVarSubst,
  parseLinkSubst,
  parseCondSubst,
  parseHtmlTag,
];

const rootParsers = [
  parseRootTextContent,
  parseVarSubst,
  parseLinkSubst,
  parseCondSubst,
  parseHtmlTag,
];

const parseRoot = (
  args: VarArgsClass<Input>,
) => parseContinuousArray(rootParsers, args);

/*
 * `expand2react` takes a translated string and
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
export default function expand2react(
  source: string,
  args?: ?VarArgsObject<Input>,
): Output {
  return expand2reactWithVarArgsInstance(
    source,
    args ? new VarArgs(args) : null,
  );
}

export function expand2reactWithVarArgsInstance(
  source: string,
  args?: ?VarArgsClass<Input>,
): Output {
  const result = expand<$ReadOnlyArray<Output>, Input>(
    parseRoot,
    source,
    args,
  );
  if (typeof result === 'string') {
    return result;
  }
  return result.length ? (
    result.length > 1
      ? React.createElement(React.Fragment, null, ...result)
      : result[0]
  ) : '';
}

export const l = (
  key: string,
  args?: ?VarArgsObject<Input>,
): Output => expand2react(lActual(key), args);

export const ln = (
  skey: string,
  pkey: string,
  val: number,
  args?: ?VarArgsObject<Input>,
): Output => expand2react(lnActual(skey, pkey, val), args);

export const lp = (
  key: string,
  context: string,
  args?: ?VarArgsObject<Input>,
): Output => expand2react(lpActual(key, context), args);
