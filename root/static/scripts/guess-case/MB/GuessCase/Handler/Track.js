/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags.js';
import * as modes from '../../../modes.js';

import GuessCaseHandler from './Base.js';

// Track specific GuessCase functionality
class GuessCaseTrackHandler extends GuessCaseHandler {
  removeBonusInfo(inputString: string): string {
    return inputString
      .replace(/[([]?bonus(\s+track)?s?\s*[)\]]?$/i, '')
      .replace(/[([]?retail(\s+version)?\s*[)\]]?$/i, '');
  }

  /*
   * Guess the trackname given in string is, and
   * returns the guessed name.
   */
  process(inputString: string): string {
    return modes[this.modeName].fixVinylSizes(super.process(inputString));
  }

  getWordsForProcessing(inputString: string): Array<string> {
    const preppedString = modes[this.modeName].preProcessTitles(
      this.removeBonusInfo(inputString),
    );
    return modes[this.modeName].prepExtraTitleInfo(
      this.input.splitWordsAndPunctuation(preppedString),
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
      if (!this.regexes.TRACK_DATATRACK) {
        // Data tracks
        this.regexes.TRACK_DATATRACK = /^([([]?\s*data(\s+track)?\s*[)\]]?$)/i;
        // Silence
        this.regexes.TRACK_SILENCE = /^([([]?\s*(silen(t|ce)|blank)(\s+track)?\s*[)\]]?)$/i;
        // Untitled
        this.regexes.TRACK_UNTITLED = /^([([]?\s*untitled(\s+track)?\s*[)\]]?)$/i;
        // Unknown
        this.regexes.TRACK_UNKNOWN = /^([([]?\s*(unknown|bonus|hidden)(\s+track)?\s*[)\]]?)$/i;
        // Any number of question marks
        this.regexes.TRACK_MYSTERY = /^\?+$/i;
      }
      if (inputString.match(this.regexes.TRACK_DATATRACK)) {
        return this.specialCaseValues.SPECIALCASE_DATA_TRACK;
      } else if (inputString.match(this.regexes.TRACK_SILENCE)) {
        return this.specialCaseValues.SPECIALCASE_SILENCE;
      } else if (inputString.match(this.regexes.TRACK_UNTITLED)) {
        return this.specialCaseValues.SPECIALCASE_UNTITLED;
      } else if (inputString.match(this.regexes.TRACK_UNKNOWN)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.TRACK_MYSTERY)) {
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
      !modes[this.modeName].doWord()
    ) {
      if (this.input.matchCurrentWord(/7in/i)) {
        this.output.appendSpaceIfNeeded();
        this.output.appendWord('7"');
        flags.resetContext();
        flags.context.spaceNextWord = false;
        flags.context.forceCaps = false;
      } else if (this.input.matchCurrentWord(/12in/i)) {
        this.output.appendSpaceIfNeeded();
        this.output.appendWord('12"');
        flags.resetContext();
        flags.context.spaceNextWord = false;
        flags.context.forceCaps = false;
      } else {
        // Handle other cases (e.g. normal words)
        this.output.appendSpaceIfNeeded();
        this.input.capitalizeCurrentWord();

        this.output.appendCurrentWord();
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
