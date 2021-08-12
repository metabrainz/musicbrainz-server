/*
 * Copyright (C) 2013 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../../../../common/MB';
import * as flags from '../../../flags';
import * as modes from '../../../modes';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Place specific GuessCase functionality
MB.GuessCase.Handler.Place = function (gc) {
  var self = MB.GuessCase.Handler.Base(gc);

  // Checks special cases
  self.checkSpecialCase = function () {
    return self.NOT_A_SPECIALCASE;
  };

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   */
  self.doWord = function () {
    (
      self.doIgnoreWords() ||
      modes[gc.modeName].doWord() ||
      self.doNormalWord()
    );
    flags.context.number = false;
    return null;
  };

  // Guesses the sortname for place aliases
  self.guessSortName = function (is) {
    return self.sortCompoundName(is, self.moveArticleToEnd);
  };

  return self;
};
