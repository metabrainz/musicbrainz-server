/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Performs a lexicographical comparison of two strings. If sorting
 * strings for display, you'll generally want to use the `compare`
 * function from our i18n module instead. But if you're sorting machine
 * data, or if a locale-sensitive sort just isn't necessary, this can
 * be used as a fast alternative. It's very important to note that
 * Intl.Collator's `compare` function can return 0 even if the strings
 * aren't exactly equal, particularly if either contains non-printable
 * characters.
 */
export function compareStrings(a: string, b: string): number {
  return a < b ? -1 : (a > b ? 1 : 0);
}

/*
 * The `compareStrings` implementation above works with numbers too,
 * but a separate function (1) allows for separate Flow types and (2)
 * keeps the function calls monomorphic. There's no real benefit to
 * importing this if you're simply comparing two numbers as part of a
 * larger sort function; it's mainly useful for passing to .sort()
 * directly.
 */
export function compareNumbers(a: number, b: number): number {
  return a - b;
}
