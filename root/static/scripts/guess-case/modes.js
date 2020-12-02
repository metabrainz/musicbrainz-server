/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as ReactDOMServer from 'react-dom/server';

import getBooleanCookie from '../common/utility/getBooleanCookie';
import {capitalize} from '../common/utility/strings';

import {
  isPrepBracketWord,
  isPrepBracketSingleWord,
  turkishUpperCase,
  turkishLowerCase,
} from './utils';

/*
 * Words which are always written lowercase.
 * -------------------------------------------------------
 * tma      2005-01-29  first version
 * keschte  2005-04-17  added french lowercase characters
 * keschte  2005-06-14  added "tha" to be handled like "the"
 * warp     2011-02-01  added da, de, di, fe, fi, ina, inna
 * dpmittal 2016-12-20  added Turkish lowercase words
 */
const LOWER_CASE_WORDS = /^(a|an|and|as|at|but|by|da|de|di|fe|fi|for|in|ina|inna|n|nor|o|of|on|or|tha|the|to)$/;
const LOWER_CASE_WORDS_TURKISH = /^(ve|ile|ya|veya|yahut|ki|mı|mi|mu|mü|mısın|musun|mudur|mıdır|midir|miyim|misin|misiniz|mısınız|müsün|müyüm|müsünüz|mıyım|muyum|musunuz|miyiz|mıyız|muyuz|müyüz|müdür)$/;

/*
 * Words which are always written uppercase.
 * -------------------------------------------------------
 * keschte  2005-01-31  first version
 * various  2005-05-05  added "FM...PM"
 * keschte  2005-05-24  removed AM, PM because they yielded false positives
 *                        e.g. "I AM stupid"
 * keschte  2005-07-10  added uk, bpm
 * keschte  2005-07-20  added ussr, usa, ok, nba, rip, ny, classical words,
 *                        hip-hop artists
 * keschte  2005-10-24  removed AD
 * keschte  2005-11-15  removed RIP (Let Rip) is not R.I.P.
 */
const UPPER_CASE_WORDS = /^(dj|mc|tv|mtv|ep|lp|ymca|nyc|ny|ussr|usa|r&b|bbc|fm|bc|ac|dc|uk|bpm|ok|nba|rza|gza|odb|dmx|2xlc)$/;
const ROMAN_NUMERALS = /^m{0,4}(cm|cd|d?c{0,3})(xc|xl|l?x{0,3})(ix|iv|v?i{0,3})$/;

/* eslint-disable no-multi-spaces */
const PREPROCESS_FIXLIST = [
  // trim spaces from brackets.
  [/(^|\s)([\(\{\[])\s+($|\b)/i, '$2'], // spaces after opening brackets
  [/(\b|^)\s+([\)\}\]])($|\b)/i, '$2'], // spaces before closing brackets

  // vinyl
  [/(\s|^|\()(\d+)''(\s|$)/i,      '$2"'], // 12'' -> 12"
  [/(\s|^|\()(\d+)in(ch)?(\s|$)/i, '$2"'], // 12in -> 12"

  /*
   * combined word hacks, e.g. replace spaces with underscores ("a cappella"
   * -> a_capella), such that it can be handled correctly in post-processing.
   */
  [/(\b|^)a\s?c+ap+el+a(\b)/i, 'a_cappella'], // A Capella preprocess
  [/(\b|^)oc\sremix(\b)/i,     'oc_remix'],   // OC ReMix preprocess
  [/(\b|^)a\/k\/a(\b)/ig,      'a_k_a_'],     // a.k.a. preprocess
  [/(\b|^)a\.k\.a\.(\s)/ig,    'a_k_a_'],
];

// see combined words hack in preProcessTitles
const POSTPROCESS_FIXLIST = [
  [/(\b|^)a_cappella(\b)/, 'a cappella'], // a_cappella inside brackets
  [/(\b|^)A_cappella(\b)/, 'A Cappella'], // a_cappella outside brackets
  [/(\b|^)oc_remix(\b)/i,  'OC ReMix'],   // oc_remix
  [/(\b|^)Re_edit(\b)/,    're-edit'],    // re_edit inside brackets
  [/(\b|^)a_k_a_(\b|$)/ig, 'a.k.a.'],     // a.k.a. lowercase
  [/(\b|^)aka(\b|$)/ig,    'aka'],        // aka lowercase

  /*
   * "fe" is considered a lowercase word, but "Santa Fe" is very common in
   * song titles, so change that "fe" back into "Fe".
   */
  [/(\b|^)Santa fe(\b|$)/g,        'Santa Fe'],
  [/(\b|^)R\s*&\s*B(\b)/i,         'R&B'],
  [/(\b|^)\[live\](\b)/i,          '(live)'],
  [/(\b|^)Djs(\b)/i,               'DJs'],
  [/(\b|^)imac(\b)/i,              'iMac'], // Apple products
  [/(\b|^)ipad(\b)/i,              'iPad'],
  [/(\b|^)iphone(\b)/i,            'iPhone'],
  [/(\b|^)ipod(\b)/i,              'iPod'],
  [/(\b|^)itunes(\b)/i,            'iTunes'],
  [/(\s|^)Rock '?n'? Roll(\s|$)/i, "Rock 'n' Roll"],
  [/(\b)w([/／])o(\b)/i,           'w$2o'], // w/o should be lowercase
  [/(\b)f([.．/／])(\b)/i,         'f$2'], // f. and f/ should be lowercase
];
/* eslint-enable no-multi-spaces */

function replaceMatch(matches, is, regex, replacement) {
  // get reference to first set of parentheses
  const a = matches[1] || '';

  // get reference to last set of parentheses
  const b = matches[matches.length - 1] || '';

  // compile replace string
  return is.replace(regex, [a, replacement, b].join(''));
}

/*
 * Iterate through the `fixes` array and apply the fixes to string `is`.
 *
 * @param is     the input string
 * @param fixes  the list of fix objects to apply
 */
function runFixes(is, fixes) {
  fixes.forEach(function (fix) {
    const [regex, replacement] = fix;
    let matches;

    if (regex.global) {
      let oldis;
      while ((matches = regex.exec(is))) {
        oldis = is;
        is = replaceMatch(matches, is, regex, replacement);
        if (oldis === is) {
          break;
        }
      }
    } else if ((matches = is.match(regex)) !== null) {
      is = replaceMatch(matches, is, regex, replacement);
    }
  });

  return is;
}

const DefaultMode = {
  description: '',

  isLowerCaseWord(w) {
    return LOWER_CASE_WORDS.test(w);
  },

  isRomanNumber(w) {
    return getBooleanCookie('guesscase_roman') && ROMAN_NUMERALS.test(w);
  },

  isSentenceCaps() {
    return true;
  },

  isUpperCaseWord(w) {
    return UPPER_CASE_WORDS.test(w);
  },

  name: '',

  toLowerCase(str) {
    return str.toLowerCase();
  },

  toUpperCase(str) {
    return str.toUpperCase();
  },

  /*
   * Pre-process to find any lowercase_bracket word that needs to be put into
   * parentheses. Starts from the back and collects words that belong into the
   * brackets, e.g.
   * My Track Extended Dub remix => My Track (extended dub remix)
   * My Track 12" remix => My Track (12" remix)
   */
  prepExtraTitleInfo(words) {
    const lastWord = words.length - 1;
    let wi = lastWord;
    let handlePreProcess = false;

    while (wi >= 0 && (
      // skip whitespace
      (words[wi] === ' ') ||

      // vinyl (7" or 12")
      (words[wi] === '"' &&
        (words[wi - 1] === '7' || words[wi - 1] === '12')) ||
      ((words[wi + 1] || '') === '"' &&
        (words[wi] === '7' || words[wi] === '12')) ||

      isPrepBracketWord(words[wi])
    )) {
      handlePreProcess = true;
      wi--;
    }

    /*
     * Down-N-Dirty (lastWord = dirty)
     * Dance,Dance,Dance (lastWord = dance) get matched by the preprocessor,
     * but are a single word which can occur at the end of the string.
     * therefore, we don't put the single word into parens.
     */

    /*
     * trackback the skipped spaces spaces, and then slurp the next word, so
     * see which word we found.
     */
    if (wi < lastWord) {
      // the word at wi broke out of the loop above, is not extra title info
      wi++;
      while (words[wi] === ' ' && wi < lastWord) {
        wi++; // skip whitespace
      }

      /*
       * If we have a single word that needs to be put in parentheses, consult
       * the list of words were we don't do that, otherwise continue.
       */
      const probe = words[lastWord];
      if (wi === lastWord && isPrepBracketSingleWord(probe)) {
        handlePreProcess = false;
      }

      if (handlePreProcess && wi > 0 && wi <= lastWord) {
        let newWords = words.slice(0, wi);

        if (newWords[wi - 1] === '(') {
          newWords.pop();
        }

        if (newWords[wi - 1] === '-') {
          newWords.pop();
        }

        newWords.push('(');
        newWords = newWords.concat(words.slice(wi, words.length));
        newWords.push(')');
        words = newWords;
      }
    }

    return words;
  },

  /*
   * Take care of misspellings that need to be fixed before splitting the
   * string into words.
   * Note: this function is run before release and track guess types
   * (not for artist)
   *
   * keschte  2005-11-10  first version
   */
  preProcessTitles(is) {
    return runFixes(is, PREPROCESS_FIXLIST);
  },

  /*
   * Collect words from processed wordlist and apply minor fixes that
   * aren't handled in the specific function.
   */
  runPostProcess(is) {
    return runFixes(is, POSTPROCESS_FIXLIST);
  },

  /*
   * Look for and convert vinyl expressions.
   * - Look only at substrings which start with ' ' or '('.
   * - Convert 7', 7'', 7", 7in, and 7inch to '7" ' (followed by space).
   * - Convert 12', 12'', 12", 12in, and 12inch to '12" ' (followed by space).
   * - Do not convert strings like 80's.
   */
  fixVinylSizes(is) {
    return is
      .replace(/(\s+|\()(7|10|12)(?:inch\b|in\b|'|''|")([^s]|$)/ig, '$1$2"$3')
      .replace(/((?:\s+|\()(?:7|10|12)")([^),\s])/, '$1 $2');
  },

  /*
   * Delegate function for mode-specific word handling. This is mostly used
   * for context-based title changes.
   *
   * @return  `false`, such that the normal word handling can take place for
   *          the current word. If that should not be done, return `true`.
   */
  doWord() {
    return false;
  },
};

export const English = Object.assign({}, DefaultMode, {
  description: ReactDOMServer.renderToStaticMarkup(exp.l(
    `This mode capitalises almost all words, with some words (mainly articles 
     and short prepositions) lowercased. Some words may need to be manually 
     capitalised to follow the {url|English capitalisation guidelines}.`,
    {
      url:
        {href: 'https://musicbrainz.org/doc/Style/Language/English', target: '_blank'},
    },
  )),

  /*
   * This changes key names in titles to follow
   * the English classical music guidelines.
   * See https://musicbrainz.org/doc/Style/Classical/Language/English#Keys
   */
  fixEnglishKeyNames(is) {
    return is.replace(
      /\bin ([a-g])(?:[\s-]([Ff]lat|[Ss]harp))?\s(dorian|lydian|major|minor|mixolydian)(?:\b|$)/ig,
      function (match, p1, p2, p3) {
        return 'in ' + p1.toUpperCase() +
          (p2 ? '-' + p2.toLowerCase() : '') +
          ' ' + p3.toLowerCase();
      },
    );
  },

  isSentenceCaps() {
    return false;
  },

  name: 'English',

  runPostProcess(is) {
    is = DefaultMode.runPostProcess(is);
    is = this.fixEnglishKeyNames(is);
    return is;
  },
});

export const French = Object.assign({}, DefaultMode, {
  description: ReactDOMServer.renderToStaticMarkup(exp.l(
    `This mode capitalises titles as sentence mode, but also inserts spaces 
     before semicolons, colons, exclamation marks and question marks, 
     and inside guillemets. Some words may need to be manually capitalised 
     to follow the {url|French capitalisation guidelines}.`,
    {
      url: {href: 'https://musicbrainz.org/doc/Style/Language/French', target: '_blank'},
    },
  )),

  name: 'French',

  runPostProcess(is) {
    return DefaultMode.runPostProcess(is)
      .replace(/([!\?;:]+)/gi, ' $1')
      .replace(/([«]+)/gi, '$1 ')
      .replace(/([»]+)/gi, ' $1')
      .replace(/^(Le\s|La\s|Les\s|L[’'])(\S+)$/gi,
               (_, m1, m2) => m1.replace('\'', '’') + capitalize(m2));
  },
});

export const Sentence = Object.assign({}, DefaultMode, {
  description: ReactDOMServer.renderToStaticMarkup(exp.l(
    `This mode capitalises the first word of a sentence, most other words 
     are lowercased. Some words, often proper nouns, may need to be manually 
     fixed according to the {url|relevant language guidelines}.`,
    {
      url:
        {href: 'https://musicbrainz.org/doc/Style/Language', target: '_blank'},
    },
  )),

  name: 'Sentence',
});
export const Turkish = Object.assign({}, DefaultMode, {
  description: ReactDOMServer.renderToStaticMarkup(exp.l(
    `This mode handles the Turkish capitalisation of 'i' ('İ') and 'ı' ('I').
     Some words may need to be manually corrected according to 
     the {url|Turkish language guidelines}.`,
    {
      url: {
        href: 'https://musicbrainz.org/doc/Style/Language/Turkish',
        target: '_blank',
      },
    },
  )),

  isLowerCaseWord(w) {
    return LOWER_CASE_WORDS.test(w) || LOWER_CASE_WORDS_TURKISH.test(w);
  },

  isSentenceCaps() {
    return false;
  },

  name: 'Turkish',

  toLowerCase: turkishLowerCase,

  toUpperCase: turkishUpperCase,
});
