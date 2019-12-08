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

// Track specific GuessCase functionality
MB.GuessCase.Handler.Track = function (gc) {
    var self = MB.GuessCase.Handler.Base(gc);

    self.removeBonusInfo = function (is) {
        return is
            .replace(/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, "")
            .replace(/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, "");
    };

    /*
     * Guess the trackname given in string is, and
     * returns the guessed name.
     *
     * @param    is       the inputstring
     * @returns os        the processed string
     */

    self.process = _.wrap(self.process, function (process, os) {
        return gc.mode.fixVinylSizes(process(os));
    });

    self.getWordsForProcessing = function (is) {
        is = gc.mode.preProcessTitles(self.removeBonusInfo(is));
        return gc.mode.prepExtraTitleInfo(gc.i.splitWordsAndPunctuation(is));
    };

    /*
     * Detect if UntitledTrackStyle and DataTrackStyle needs
     * to be applied.
     *
     * - data [track]            -> [data track]
     * - silence|silent [track]    -> [silence]
     * - untitled [track]        -> [untitled]
     * - unknown|bonus [track]    -> [unknown]
     */
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.TRACK_DATATRACK) {
                // Data tracks
                gc.re.TRACK_DATATRACK = /^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i;
                // Silence
                gc.re.TRACK_SILENCE = /^([\(\[]?\s*(silen(t|ce)|blank)(\s+track)?\s*[\)\]]?)$/i;
                // Untitled
                gc.re.TRACK_UNTITLED = /^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i;
                // Unknown
                gc.re.TRACK_UNKNOWN = /^([\(\[]?\s*(unknown|bonus|hidden)(\s+track)?\s*[\)\]]?)$/i;
                // Any number of question marks
                gc.re.TRACK_MYSTERY = /^\?+$/i;
            }
            if (is.match(gc.re.TRACK_DATATRACK)) {
                return self.SPECIALCASE_DATA_TRACK;

            } else if (is.match(gc.re.TRACK_SILENCE)) {
                return self.SPECIALCASE_SILENCE;

            } else if (is.match(gc.re.TRACK_UNTITLED)) {
                return self.SPECIALCASE_UNTITLED;

            } else if (is.match(gc.re.TRACK_UNKNOWN)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.TRACK_MYSTERY)) {
                return self.SPECIALCASE_UNKNOWN;
            }
        }
        return self.NOT_A_SPECIALCASE;
    };

    /*
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles FeaturingArtistStyle
     */
    self.doWord = function () {
        if (
          !self.doIgnoreWords() &&
          !self.doFeaturingArtistStyle() &&
          !gc.mode.doWord()
        ) {
            if (gc.i.matchCurrentWord(/7in/i)) {
                gc.o.appendSpaceIfNeeded();
                gc.o.appendWord('7"');
                flags.resetContext();
                flags.context.spaceNextWord = false;
                flags.context.forceCaps = false;
            } else if (gc.i.matchCurrentWord(/12in/i)) {
                gc.o.appendSpaceIfNeeded();
                gc.o.appendWord('12"');
                flags.resetContext();
                flags.context.spaceNextWord = false;
                flags.context.forceCaps = false;
            } else {
                // Handle other cases (e.g. normal words)
                gc.o.appendSpaceIfNeeded();
                gc.i.capitalizeCurrentWord();

                gc.o.appendCurrentWord();
                flags.resetContext();
                flags.context.spaceNextWord = true;
                flags.context.forceCaps = false;
            }
        }
        flags.context.number = false;
        return null;
    };

    // Guesses the sortname for recordings (for aliases)
    self.guessSortName = self.moveArticleToEnd;

    return self;
};
