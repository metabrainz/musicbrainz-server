/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags';
import input from '../Input';
import gc from '../Main';
import output from '../Output';

import GuessCaseHandler from './Base';

// Label specific GuessCase functionality
class GuessCaseLabelHandler extends GuessCaseHandler {
  /*
   * Checks special cases of labels
   * - empty, unknown -> [unknown]
   * - none, no label, not applicable, n/a -> [no label]
   */
  checkSpecialCase(inputString) {
    if (inputString) {
      if (!gc.regexes.LABEL_EMPTY) {
        // Match empty
        gc.regexes.LABEL_EMPTY = /^\s*$/i;
        // Match "unknown" and variants
        gc.regexes.LABEL_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
        // Match "none" and variants
        gc.regexes.LABEL_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
        // Match "no label" and variants
        gc.regexes.LABEL_NOLABEL = /^[\(\[]?\s*no[\s-]+label\s*[\)\]]?$/i;
        // Match "not applicable" and variants
        gc.regexes.LABEL_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
        // Match "n/a" and variants
        gc.regexes.LABEL_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
      }
      if (inputString.match(gc.regexes.LABEL_EMPTY)) {
        return this.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.LABEL_UNKNOWN)) {
        return this.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.LABEL_NONE)) {
        return this.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.LABEL_NOLABEL)) {
        return this.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.LABEL_NOTAPPLICABLE)) {
        return this.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.LABEL_NA)) {
        return this.SPECIALCASE_UNKNOWN;
      }
    }
    return this.NOT_A_SPECIALCASE;
  }

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   */
  doWord() {
    output.appendSpaceIfNeeded();
    input.capitalizeCurrentWord();
    output.appendCurrentWord();

    flags.resetContext();
    flags.context.number = false;
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
    return null;
  }

  // Guesses the sortname for label aliases
  guessSortName(inputString) {
    return this.sortCompoundName(
      inputString,
      (inputString) => this.moveArticleToEnd(inputString),
    );
  }
}

export default GuessCaseLabelHandler;
