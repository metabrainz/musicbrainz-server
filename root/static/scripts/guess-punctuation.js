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
 * typographic quotes or apostrophes in recognized constructions. Ambiguous
 * straight single quotes are left unchanged.
 *
 * @param {string} inputString - The string to guess punctuation for.
 * @returns {string} - The string with guessed punctuation.
 */
export default function guessPunctuation(inputString: string): string {
  return inputString
    // 'n' is an elision rather than text enclosed in single quotes.
    .replace(
      /(^|[^\p{L}\p{N}])'(n)'(?=[^\p{L}\p{N}]|$)/giu,
      '$1’$2’',
    )
    // Match quote pairs only when they are bounded by non-word characters.
    .replace(
      /(^|[^\p{L}\p{N}])'(.+?)'(?=[^\p{L}\p{N}]|$)/gu,
      '$1‘$2’',
    )
    // Common English contractions and possessives.
    .replace(
      /(\p{L})'(?=(?:d|ll|m|re|ve)(?!\p{L}))/giu,
      '$1’',
    )
    .replace(/([\p{L}\p{N}])'(?=s(?!\p{L}))/giu, '$1’')
    .replace(/(\p{L}n)'(?=t(?!\p{L}))/giu, '$1’')
    // Common English elisions at the start of a word.
    .replace(
      /(^|[^\p{L}\p{N}])'(?=(?:bout|cause|cept|em|gainst|round|til|twas|tween|twere)(?!\p{L}))/giu,
      '$1’',
    )
    // Terminal elisions are deliberately limited to known forms.
    .replace(
      /\b(lovin|talkin)'(?=[^\p{L}]|$)/gi,
      '$1’',
    )
    // Apostrophes standing in for the century in abbreviated years.
    .replace(
      /(^|[^\p{L}\p{N}])'(?=\d{2}(?!\d))/gu,
      '$1’',
    )
    // Common Greek elisions present in MusicBrainz titles.
    .replace(
      /(^|[^\p{L}])(Σ|Υπ)'(?=[^\p{L}]|$)/giu,
      '$1$2’',
    );
}
