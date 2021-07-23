/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// Holds the state of the current GC operation.
export type GuessCaseContextT = {
  acronym: boolean,
  acronym_split: boolean,
  colon: boolean,
  ellipsis: boolean,
  forceCaps: boolean,
  hyphen: boolean,
  number: boolean,
  numberSplitChar: string | null,
  numberSplitExpect: boolean,
  openBrackets: Array<string>,
  openedSingleQuote: boolean,
  openingBracket: boolean,
  singlequote: boolean,
  slurpExtraTitleInformation: boolean,
  spaceNextWord: boolean,
  whitespace: boolean,
};

export const context: GuessCaseContextT = {
  acronym: false,
  acronym_split: false,
  colon: false,
  ellipsis: false,
  forceCaps: false,
  hyphen: false,
  number: false,
  numberSplitChar: null,
  numberSplitExpect: false,
  openBrackets: [],
  openedSingleQuote: false,
  openingBracket: false,
  singlequote: false,
  slurpExtraTitleInformation: false,
  spaceNextWord: false,
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
export function isInsideBrackets(): boolean {
  return context.openBrackets.length > 0;
}

export function pushBracket(bracket: string): void {
  context.openBrackets.push(bracket);
}

export function popBracket(): string | null {
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

function getCorrespondingBracket(bracketChar: string): string {
  return bracketChars.test(bracketChar) ? bracketPairs[bracketChar] : '';
}

export function getCurrentCloseBracket(): string | null {
  const openBracket = context.openBrackets[context.openBrackets.length - 1];
  return openBracket ? getCorrespondingBracket(openBracket) : null;
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
