/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * IDEOGRAPHIC SPACE U+3000 serves as fullwidth of ASCII space 0x20;
 * U+FF01-FF5E are fullwidth of ASCII printable characters 0x21-7E;
 * U+FF5F-FF60 are fullwidth white/double parenthesis U+2985-2986;
 * U+FFE0-FFE6 are fullwidth of a few Latin-1 supplement characters.
 */
const fullwidthLatinRegexp = /[\u3000\uFF01-\uFF60\uFFE0-\uFFE6]/;

export const hasFullwidthLatin = function (str: ?string): boolean {
  return fullwidthLatinRegexp.test(str || '');
};

export const fromFullwidthLatin = function (str: ?string): string {
  return (str || '')
    .replace(/\u3000/g, ' ')
    .replace(/[\uFF01-\uFF5E]/g, function (c) {
      return String.fromCharCode(0x00FF & c.charCodeAt(0) + 0x20);
    })
    .replace(/\uFF5F/g, '\u2985')
    .replace(/\uFF60/g, '\u2986')
    .replace(/\uFFE0/g, '\u00A2')
    .replace(/\uFFE1/g, '\u00A3')
    .replace(/\uFFE2/g, '\u00AC')
    .replace(/\uFFE3/g, '\u00AF')
    .replace(/\uFFE4/g, '\u00A6')
    .replace(/\uFFE5/g, '\u00A5')
    .replace(/\uFFE6/g, '\u20A9');
};

export const toFullwidthLatin = function (str: ?string): string {
  return (str || '')
    .replace(/\s/g, '\u3000')
    .replace(/[\x21-\x7E]/g, function (c) {
      return String.fromCharCode(0xFF00 | (c.charCodeAt(0) - 0x20));
    })
    .replace(/\u2985/g, '\uFF5F')
    .replace(/\u2986/g, '\uFF60')
    .replace(/\u00A2/g, '\uFFE0')
    .replace(/\u00A3/g, '\uFFE1')
    .replace(/\u00AC/g, '\uFFE2')
    .replace(/\u00AF/g, '\uFFE3')
    .replace(/\u00A6/g, '\uFFE4')
    .replace(/\u00A5/g, '\uFFE5')
    .replace(/\u20A9/g, '\uFFE6');
};
