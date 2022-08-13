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
import input from '../Input.js';
import gc from '../Main.js';

import GuessCaseHandler from './Base.js';

// Release specific GuessCase functionality
class GuessCaseReleaseHandler extends GuessCaseHandler {
  // Checks special cases of releases
  checkSpecialCase(inputString?: string): number {
    if (inputString != null) {
      if (!gc.regexes.RELEASE_UNTITLED) {
        // Untitled
        gc.regexes.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
      }
      if (inputString.match(gc.regexes.RELEASE_UNTITLED)) {
        return this.specialCaseValues.SPECIALCASE_UNTITLED;
      }
    }
    return this.specialCaseValues.NOT_A_SPECIALCASE;
  }

  /*
   * Guess the releasename given in string is, and
   * returns the guessed name.
   *
   * @param    is        the inputString
   * @returns os        the processed string
   */
  process(inputString: string): string {
    return modes[gc.modeName].fixVinylSizes(super.process(inputString));
  }

  getWordsForProcessing(inputString: string): Array<string> {
    const preppedString = modes[gc.modeName].preProcessTitles(inputString);
    return modes[gc.modeName].prepExtraTitleInfo(
      input.splitWordsAndPunctuation(preppedString),
    );
  }

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   *
   * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
   * - Handles FeaturingArtistStyle
   */
  doWord(): boolean {
    (
      this.doFeaturingArtistStyle() ||
      modes[gc.modeName].doWord() ||
      this.doNormalWord()
    );
    flags.context.number = false;
    return true;
  }

  // Guesses the sortname for releases (for aliases)
  guessSortName(inputString: string): string {
    return this.moveArticleToEnd(inputString);
  }
}

export default GuessCaseReleaseHandler;
