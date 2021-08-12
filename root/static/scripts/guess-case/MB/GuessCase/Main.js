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

import GuessCaseAreaHandler from './Handler/Area';
import GuessCaseArtistHandler from './Handler/Artist';
import GuessCaseLabelHandler from './Handler/Label';
import GuessCasePlaceHandler from './Handler/Place';
import GuessCaseReleaseHandler from './Handler/Release';
import GuessCaseTrackHandler from './Handler/Track';
import GuessCaseWorkHandler from './Handler/Work';

MB.GuessCase = MB.GuessCase || {};

// Main class of the GC functionality
var self = {};

self.modeName = getCookie('guesscase_mode') || 'English';

// Config
self.CFG_KEEP_UPPERCASED = getCookie('guesscase_keepuppercase') !== 'false';

self.regexes = {
  // define commonly used RE's
  SPACES_DOTS: /\s|\./i,
  SERIES_NUMBER: /^(\d+|[ivx]+)$/i,
}; // holder for the regular expressions

// Member functions

function guess(handlerName, method) {
  let handler;
  const handlerPicker = {
    area: GuessCaseAreaHandler,
    artist: GuessCaseArtistHandler,
    event: GuessCaseWorkHandler,
    label: GuessCaseLabelHandler,
    place: GuessCasePlaceHandler,
    recording: GuessCaseTrackHandler,
    release: GuessCaseReleaseHandler,
    release_group: GuessCaseReleaseHandler,
    series: GuessCaseWorkHandler,
    track: GuessCaseTrackHandler,
    work: GuessCaseWorkHandler,
  };
  /*
   * Guesses the name (e.g. capitalization) or sort name (for aliases)
   * of a given entity.
   * @param {string} is The unprocessed input string.
   * @return {string} The processed string.
   */
  return function (is) {
    // Initialise flags for another run.
    flags.init();

    handler = handler || new handlerPicker[handlerName]();

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
  guess: guess('area', 'process'),
  sortname: guess('area', 'guessSortName'),
};

MB.GuessCase.artist = {
  guess: guess('artist', 'process'),
  sortname: guess('artist', 'guessSortName'),
};

MB.GuessCase.event = {
  guess: guess('event', 'process'),
  sortname: guess('event', 'guessSortName'),
};

// For instruments, all we need to do is lowercase the string
function lowercaseInstrumentName(name) {
  return name.toLowerCase();
}

MB.GuessCase.instrument = {
  guess: lowercaseInstrumentName,
  sortname: lowercaseInstrumentName,
};

MB.GuessCase.label = {
  guess: guess('label', 'process'),
  sortname: guess('label', 'guessSortName'),
};

MB.GuessCase.place = {
  guess: guess('place', 'process'),
  sortname: guess('place', 'guessSortName'),
};

MB.GuessCase.release = {
  guess: guess('release', 'process'),
  sortname: guess('release', 'guessSortName'),
};

MB.GuessCase.release_group = {
  guess: guess('release_group', 'process'),
  sortname: guess('release_group', 'guessSortName'),
};

MB.GuessCase.track = {
  guess: guess('track', 'process'),
  sortname: guess('track', 'guessSortName'),
};

MB.GuessCase.recording = {
  guess: guess('recording', 'process'),
  sortname: guess('recording', 'guessSortName'),
};

MB.GuessCase.series = {
  guess: guess('series', 'process'),
  sortname: guess('series', 'guessSortName'),
};

MB.GuessCase.work = {
  guess: guess('work', 'process'),
  sortname: guess('work', 'guessSortName'),
};

export default self;
