/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../../../../common/MB';
import * as flags from '../../../flags';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Label specific GuessCase functionality
MB.GuessCase.Handler.Label = function (gc) {
    var self = MB.GuessCase.Handler.Base(gc);

    /*
     * Checks special cases of labels
     * - empty, unknown -> [unknown]
     * - none, no label, not applicable, n/a -> [no label]
     */
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.LABEL_EMPTY) {
                // Match empty
                gc.re.LABEL_EMPTY = /^\s*$/i;
                // Match "unknown" and variants
                gc.re.LABEL_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
                // Match "none" and variants
                gc.re.LABEL_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
                // Match "no label" and variants
                gc.re.LABEL_NOLABEL = /^[\(\[]?\s*no[\s-]+label\s*[\)\]]?$/i;
                // Match "not applicable" and variants
                gc.re.LABEL_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
                // Match "n/a" and variants
                gc.re.LABEL_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
            }
            if (is.match(gc.re.LABEL_EMPTY)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_UNKNOWN)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NONE)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NOLABEL)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NOTAPPLICABLE)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NA)) {
                return self.SPECIALCASE_UNKNOWN;
            }
        }
        return self.NOT_A_SPECIALCASE;
    };

    /*
     * Delegate function which handles words not handled
     * in the common word handlers.
     */
    self.doWord = function () {
        gc.o.appendSpaceIfNeeded();
        gc.i.capitalizeCurrentWord();
        gc.o.appendCurrentWord();

        flags.resetContext();
        flags.context.number = false;
        flags.context.forceCaps = false;
        flags.context.spaceNextWord = true;
        return null;
    };

    // Guesses the sortname for label aliases
    self.guessSortName = function (is) {
        return self.sortCompoundName(is, self.moveArticleToEnd);
    };

    return self;
};
