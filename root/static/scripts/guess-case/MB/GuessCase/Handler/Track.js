/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags';
import * as modes from '../../../modes';
import input from '../Input';
import gc from '../Main';
import output from '../Output';

import GuessCaseHandler from './Base';

// Track specific GuessCase functionality
class GuessCaseTrackHandler extends GuessCaseHandler {
  removeBonusInfo(inputString: string): string {
    return inputString
      .replace(/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, '')
      .replace(/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, '');
  }

  /*
   * Guess the trackname given in string is, and
   * returns the guessed name.
   */
  process(inputString: string): string {
    return modes[gc.modeName].fixVinylSizes(super.process(inputString));
  }

  getWordsForProcessing(inputString: string): Array<string> {
    const preppedString = modes[gc.modeName].preProcessTitles(
      this.removeBonusInfo(inputString),
    );
    return modes[gc.modeName].prepExtraTitleInfo(
      input.splitWordsAndPunctuation(preppedString),
    );
  }

  /*
   * Detect if UntitledTrackStyle and DataTrackStyle needs
   * to be applied.
   *
   * - data [track]            -> [data track]
   * - silence|silent [track]    -> [silence]
   * - untitled [track]        -> [untitled]
   * - unknown|bonus [track]    -> [unknown]
   */
  checkSpecialCase(inputString?: string): number {
    if (inputString != null) {
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
      if (inputString.match(gc.regexes.TRACK_DATATRACK)) {
        return this.specialCaseValues.SPECIALCASE_DATA_TRACK;
      } else if (inputString.match(gc.regexes.TRACK_SILENCE)) {
        return this.specialCaseValues.SPECIALCASE_SILENCE;
      } else if (inputString.match(gc.regexes.TRACK_UNTITLED)) {
        return this.specialCaseValues.SPECIALCASE_UNTITLED;
      } else if (inputString.match(gc.regexes.TRACK_UNKNOWN)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.TRACK_MYSTERY)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      }
    }
    return this.specialCaseValues.NOT_A_SPECIALCASE;
  }

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   *
   * - Handles FeaturingArtistStyle
   */
  doWord(): boolean {
    if (
      !this.doIgnoreWords() &&
      !this.doFeaturingArtistStyle() &&
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
    return true;
  }

  // Guesses the sortname for recordings (for aliases)
  guessSortName(inputString: string): string {
    return this.moveArticleToEnd(inputString);
  }
}

export default GuessCaseTrackHandler;
