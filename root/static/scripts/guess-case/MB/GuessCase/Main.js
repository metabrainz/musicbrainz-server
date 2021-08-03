/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../../../common/MB';
import getCookie from '../../../common/utility/getCookie';
import * as flags from '../../flags';
import * as modes from '../../modes';

import Input from './Input';
import Output from './Output';

import './Handler/Base';
import './Handler/Area';
import './Handler/Artist';
import './Handler/Label';
import './Handler/Place';
import './Handler/Release';
import './Handler/Track';
import './Handler/Work';

MB.GuessCase = MB.GuessCase || {};

// Main class of the GC functionality
var self = {};

self.modeName = getCookie('guesscase_mode') || 'English';
self.mode = modes[self.modeName];

// Config
self.CFG_KEEP_UPPERCASED = getCookie('guesscase_keepuppercase') !== 'false';

// Member variables
self.input = new Input(self);
self.output = new Output(self);

self.regexes = {
  // define commonly used RE's
  SPACES_DOTS: /\s|\./i,
  SERIES_NUMBER: /^(\d+|[ivx]+)$/i,
}; // holder for the regular expressions

// Member functions

function guess(handlerName, method) {
  let handler;

  /*
   * Guesses the name (e.g. capitalization) or sort name (for aliases)
   * of a given entity.
   * @param {string} is The unprocessed input string.
   * @return {string} The processed string.
   */
  return function (is) {
    // Initialise flags for another run.
    flags.init();

    handler = handler || MB.GuessCase.Handler[handlerName](self);

    /*
     * We need to query the handler if the input string is
     * a special case, fetch the correct format, if the
     * returned case is indeed a special case.
     */
    const num = handler.checkSpecialCase(is);
    const os = handler.isSpecialCase(num)
      ? handler.getSpecialCaseFormatted(is, num)
    // if it was not a special case, start Guessing
      : handler[method].apply(handler, arguments);

    return os;
  };
}

MB.GuessCase.area = {
  guess: guess('Area', 'process'),
  sortname: guess('Area', 'guessSortName'),
};

MB.GuessCase.artist = {
  guess: guess('Artist', 'process'),
  sortname: guess('Artist', 'guessSortName'),
};

MB.GuessCase.label = {
  guess: guess('Label', 'process'),
  sortname: guess('Label', 'guessSortName'),
};

MB.GuessCase.place = {
  guess: guess('Place', 'process'),
  sortname: guess('Place', 'guessSortName'),
};

MB.GuessCase.release = {
  guess: guess('Release', 'process'),
  sortname: guess('Release', 'guessSortName'),
};

MB.GuessCase.release_group = MB.GuessCase.release;

MB.GuessCase.track = {
  guess: guess('Track', 'process'),
  sortname: guess('Track', 'guessSortName'),
};

MB.GuessCase.recording = MB.GuessCase.track;

MB.GuessCase.work = {
  guess: guess('Work', 'process'),
  sortname: guess('Work', 'guessSortName'),
};

/*
 * Series and Event don't have their own handler, and they use the
 * work handler because additional behavior isn't needed.
 */
MB.GuessCase.series = MB.GuessCase.work;
MB.GuessCase.event = MB.GuessCase.work;

// For instruments, all we need to do is lowercase the string
function lowercaseInstrumentName(name) {
  return name.toLowerCase();
}

MB.GuessCase.instrument = {
  guess: lowercaseInstrumentName,
  sortname: lowercaseInstrumentName,
};

export default self;
