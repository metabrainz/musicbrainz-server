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

// Release specific GuessCase functionality
class GuessCaseReleaseHandler extends GuessCaseHandler {
  // Checks special cases of releases
  checkSpecialCase(is) {
    if (is) {
      if (!gc.regexes.RELEASE_UNTITLED) {
        // Untitled
        gc.regexes.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
      }
      if (is.match(gc.regexes.RELEASE_UNTITLED)) {
        return self.SPECIALCASE_UNTITLED;
      }
    }
    return self.NOT_A_SPECIALCASE;
  }

  /*
   * Guess the releasename given in string is, and
   * returns the guessed name.
   *
   * @param    is        the inputstring
   * @returns os        the processed string
   */
  process(os) {
    return modes[gc.modeName].fixVinylSizes(super.process(os));
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
      self.doFeaturingArtistStyle() ||
      modes[gc.modeName].doWord() ||
      self.doNormalWord()
    );
    flags.context.number = false;
    return null;
  }

  // Guesses the sortname for releases (for aliases)
  guessSortName(is) {
    return this.moveArticleToEnd(is);
  }
}

export default GuessCaseReleaseHandler;
