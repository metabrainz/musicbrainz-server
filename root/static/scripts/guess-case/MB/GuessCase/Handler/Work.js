/*
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
  checkSpecialCase(is) {
    if (is) {
      if (!gc.regexes.RELEASE_UNTITLED) {
        // Untitled
        gc.regexes.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
      }
      if (is.match(gc.regexes.RELEASE_UNTITLED)) {
        return this.SPECIALCASE_UNTITLED;
      }
    }
    return this.NOT_A_SPECIALCASE;
  }

  getWordsForProcessing(is) {
    is = modes[gc.modeName].preProcessTitles(is);
    return modes[gc.modeName].prepExtraTitleInfo(
      input.splitWordsAndPunctuation(is),
    );
  }

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   *
   * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
   * - Handles FeaturingArtistStyle
   */
  doWord() {
    (
      this.doIgnoreWords() ||
      this.doFeaturingArtistStyle() ||
      modes[gc.modeName].doWord() ||
      this.doNormalWord()
    );
    flags.context.number = false;
    return null;
  }

  // Guesses the sortname for works
  guessSortName(is) {
    return this.moveArticleToEnd(is);
  }
}

export default GuessCaseWorkHandler;
