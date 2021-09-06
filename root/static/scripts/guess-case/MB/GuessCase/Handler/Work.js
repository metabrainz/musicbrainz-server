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

import GuessCaseHandler from './Base';

// Work specific GuessCase functionality
class GuessCaseWorkHandler extends GuessCaseHandler {
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
      this.doIgnoreWords() ||
      this.doFeaturingArtistStyle() ||
      modes[gc.modeName].doWord() ||
      this.doNormalWord()
    );
    flags.context.number = false;
    return true;
  }

  // Guesses the sortname for works
  guessSortName(inputString: string): string {
    return this.moveArticleToEnd(inputString);
  }
}

export default GuessCaseWorkHandler;
