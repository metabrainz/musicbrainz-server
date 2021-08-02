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

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Work specific GuessCase functionality
MB.GuessCase.Handler.Work = function (gc) {
  var self = MB.GuessCase.Handler.Base(gc);

  // Checks special cases of releases
  self.checkSpecialCase = function (is) {
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
  };

  self.getWordsForProcessing = function (is) {
    is = gc.mode.preProcessTitles(is);
    return gc.mode.prepExtraTitleInfo(gc.input.splitWordsAndPunctuation(is));
  };

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   *
   * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
   * - Handles FeaturingArtistStyle
   */
  self.doWord = function () {
    (
      self.doIgnoreWords() ||
      self.doFeaturingArtistStyle() ||
      gc.mode.doWord() ||
      self.doNormalWord()
    );
    flags.context.number = false;
    return null;
  };

  // Guesses the sortname for works
  self.guessSortName = self.moveArticleToEnd;

  return self;
};
