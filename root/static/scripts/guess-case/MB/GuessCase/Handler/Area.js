/*
 * @flow strict
 * Copyright (C) 2013 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags.js';
import * as modes from '../../../modes.js';
import trim from '../../../utils/trim.js';

import GuessCaseHandler from './Base.js';

// Area specific GuessCase functionality
class GuessCaseAreaHandler extends GuessCaseHandler {
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
      modes[this.modeName].doWord() ||
      this.doNormalWord()
    );
    flags.context.number = false;
    return true;
  }

  // Guesses the sortname for areas
  guessSortName(inputString: string): string {
    return trim(inputString);
  }
}

export default GuessCaseAreaHandler;
