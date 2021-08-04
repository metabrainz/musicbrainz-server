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
import * as modes from '../../../modes';
import input from '../Input';
import output from '../Output';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Track specific GuessCase functionality
MB.GuessCase.Handler.Track = function (gc) {
  var self = MB.GuessCase.Handler.Base(gc);

  self.removeBonusInfo = function (is) {
    return is
      .replace(/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, '')
      .replace(/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, '');
  };

  /*
   * Guess the trackname given in string is, and
   * returns the guessed name.
   *
   * @param    is       the inputstring
   * @returns os        the processed string
   */
  const baseProcess = self.process;
  self.process = function (os) {
    return modes[gc.modeName].fixVinylSizes(baseProcess(os));
  };

  self.getWordsForProcessing = function (is) {
    is = modes[gc.modeName].preProcessTitles(self.removeBonusInfo(is));
    return modes[gc.modeName].prepExtraTitleInfo(
      input.splitWordsAndPunctuation(is),
    );
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
      if (!gc.regexes.TRACK_DATATRACK) {
        // Data tracks
        gc.regexes.TRACK_DATATRACK = /^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i;
        // Silence
        gc.regexes.TRACK_SILENCE = /^([\(\[]?\s*(silen(t|ce)|blank)(\s+track)?\s*[\)\]]?)$/i;
        // Untitled
        gc.regexes.TRACK_UNTITLED = /^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i;
        // Unknown
        gc.regexes.TRACK_UNKNOWN = /^([\(\[]?\s*(unknown|bonus|hidden)(\s+track)?\s*[\)\]]?)$/i;
        // Any number of question marks
        gc.regexes.TRACK_MYSTERY = /^\?+$/i;
      }
      if (is.match(gc.regexes.TRACK_DATATRACK)) {
        return self.SPECIALCASE_DATA_TRACK;
      } else if (is.match(gc.regexes.TRACK_SILENCE)) {
        return self.SPECIALCASE_SILENCE;
      } else if (is.match(gc.regexes.TRACK_UNTITLED)) {
        return self.SPECIALCASE_UNTITLED;
      } else if (is.match(gc.regexes.TRACK_UNKNOWN)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.TRACK_MYSTERY)) {
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
      !modes[gc.modeName].doWord()
    ) {
      if (input.matchCurrentWord(/7in/i)) {
        output.appendSpaceIfNeeded();
        output.appendWord('7"');
        flags.resetContext();
        flags.context.spaceNextWord = false;
        flags.context.forceCaps = false;
      } else if (input.matchCurrentWord(/12in/i)) {
        output.appendSpaceIfNeeded();
        output.appendWord('12"');
        flags.resetContext();
        flags.context.spaceNextWord = false;
        flags.context.forceCaps = false;
      } else {
        // Handle other cases (e.g. normal words)
        output.appendSpaceIfNeeded();
        input.capitalizeCurrentWord();

        output.appendCurrentWord();
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
