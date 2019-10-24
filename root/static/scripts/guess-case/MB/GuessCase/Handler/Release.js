/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';

import MB from '../../../../common/MB';
import * as flags from '../../../flags';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Release specific GuessCase functionality
MB.GuessCase.Handler.Release = function (gc) {
    var self = MB.GuessCase.Handler.Base(gc);

    // Checks special cases of releases
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.RELEASE_UNTITLED) {
                // Untitled
                gc.re.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
            }
            if (is.match(gc.re.RELEASE_UNTITLED)) {
                return self.SPECIALCASE_UNTITLED;
            }
        }
        return self.NOT_A_SPECIALCASE;
    };

    /*
     * Guess the releasename given in string is, and
     * returns the guessed name.
     *
     * @param    is        the inputstring
     * @returns os        the processed string
     */
    self.process = _.wrap(self.process, function (process, os) {
        return gc.mode.fixVinylSizes(process(os));
    });

    self.getWordsForProcessing = function (is) {
        is = gc.mode.preProcessTitles(is);
        return gc.mode.prepExtraTitleInfo(gc.i.splitWordsAndPunctuation(is));
    };

    /*
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
     * - Handles FeaturingArtistStyle
     */
    self.doWord = function () {
        if (self.doFeaturingArtistStyle()) {
        } else if (gc.mode.doWord()) {
        } else {
            self.doNormalWord();
        }
        flags.context.number = false;
        return null;
    };

    // Guesses the sortname for releases (for aliases)
    self.guessSortName = self.moveArticleToEnd;

    return self;
};
