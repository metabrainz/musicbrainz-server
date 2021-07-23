/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// Holds the state of the current GC operation.
export const context = {
  acronym_split: false,
  colon: false,
  ellipsis: false,
  hyphen: false,
  openingBracket: false,
  singlequote: false,
  whitespace: false,
};

// Reset the context
export function resetContext() {
  context.acronym_split = false;
  context.colon = false;
  context.ellipsis = false;
  context.hyphen = false;
  context.openingBracket = false;
  context.singlequote = false;
  context.whitespace = false;
}

// Returns if there are opened brackets at current position in the string.
export function isInsideBrackets() {
  return context.openBrackets.length > 0;
}

export function pushBracket(b) {
  context.openBrackets.push(b);
}

export function popBracket() {
  const cb = getCurrentCloseBracket();
  context.openBrackets.pop();
  return cb;
}

const bracketChars = /^[()\[\]{}<>]$/;

const bracketPairs = {
  '(': ')',
  ')': '(',
  '<': '>',
  '>': '<',
  '[': ']',
  ']': '[',
  '{': '}',
  '}': '{',
};

function getCorrespondingBracket(w) {
  return bracketChars.test(w) ? bracketPairs[w] : '';
}

export function getCurrentCloseBracket() {
  const ob = context.openBrackets[context.openBrackets.length - 1];
  return ob ? getCorrespondingBracket(ob) : null;
}

// Initialise flags for another run.
export function init() {
  /*
   * Flag to force the next word to capitalize the first letter. Set to true
   * because the first word is always capitalized.
   */
  context.forceCaps = true;

  // Flag to force a space before the next word.
  context.spaceNextWord = false;

  // Reset the open/closed bracket variables.
  context.openBrackets = [];
  context.slurpExtraTitleInformation = false;

  resetContext();

  // Flag to not lowercase acronyms if followed by major punctuation.
  context.acronym = false;

  // Flag used for the number splitting routine (i.e. 10,000,000).
  context.number = false;

  // Defines whether we are inside a single-quoted section of a string.
  context.openedSingleQuote = false;

  /*
   * Defines the current number split. Note that this will not be cleared,
   * which has the side-effect of forcing the first type of number split
   * encountered to be the only one used for the entire string, assuming
   * people aren't going to be mixing grammars in titles.
   */
  context.numberSplitChar = null;
  context.numberSplitExpect = false;
}
