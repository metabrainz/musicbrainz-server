/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/**
 * Main repository of punctuation guessing logic. Used by various text fields that support punctuation guessing.
 *
 * Guesses the punctuation of a string, replacing straight single quotes with
 * typographic quotes or apostrophes as appropriate.
 *
 * @param {string} inputString - The string to guess punctuation for.
 * @returns {string} - The string with guessed punctuation.
 */
export default function guessPunctuation(inputString: string): string {
  return inputString
    // 'n' is an elision rather than text enclosed in single quotes.
    .replace(/(^|\W)'(n)'(?=\W|$)/gi, '$1’$2’')
    // Match quote pairs only when they are bounded by non-word characters.
    .replace(/(^|[^\p{L}\d])'(.+?)'(?=[^\p{L}\d]|$)/gu, '$1‘$2’')
    // Any remaining single quotes are apostrophes.
    .replace(/'/g, '’');
}
