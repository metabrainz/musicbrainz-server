/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (c) 2005 Stefan Kestenholz (keschte)
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

import MB from '../../../../common/MB';
import * as flags from '../../../flags';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/**
 * Label specific GuessCase functionality
 **/
MB.GuessCase.Handler.Label = function (gc) {
    var self = MB.GuessCase.Handler.Base(gc);

    /**
     * Checks special cases of labels
     * - empty, unknown -> [unknown]
     * - none, no label, not applicable, n/a -> [no label]
     **/
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.LABEL_EMPTY) {
                // match empty
                gc.re.LABEL_EMPTY = /^\s*$/i;
                // match "unknown" and variants
                gc.re.LABEL_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
                // match "none" and variants
                gc.re.LABEL_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
                // match "no label" and variants
                gc.re.LABEL_NOLABEL = /^[\(\[]?\s*no[\s-]+label\s*[\)\]]?$/i;
                // match "not applicable" and variants
                gc.re.LABEL_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
                // match "n/a" and variants
                gc.re.LABEL_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
            }
            var os = is;
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

    /**
     * Delegate function which handles words not handled
     * in the common word handlers.
     **/
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

    /**
     * Guesses the sortname for label aliases
     **/
    self.guessSortName = function (is) {
        return self.sortCompoundName(is, self.moveArticleToEnd);
    };

    return self;
};
