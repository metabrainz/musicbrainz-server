/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import getCookie from '../../../common/utility/getCookie.js';
import * as flags from '../../flags.js';
import {type GuessCaseModeNameT} from '../../types.js';
import {isGuessCaseModeName} from '../../utils.js';

import GuessCaseAreaHandler from './Handler/Area.js';
import GuessCaseArtistHandler from './Handler/Artist.js';
import GuessCaseHandler from './Handler/Base.js';
import GuessCaseLabelHandler from './Handler/Label.js';
import GuessCasePlaceHandler from './Handler/Place.js';
import GuessCaseReleaseHandler from './Handler/Release.js';
import GuessCaseTrackHandler from './Handler/Track.js';
import GuessCaseWorkHandler from './Handler/Work.js';

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

// Main class of the GC functionality
class GuessCase {
  CFG_KEEP_UPPERCASED: boolean;

  modeName: GuessCaseModeNameT;

  entities: {
    [entityType: string]: {
      guess: (string) => string,
      sortname: (string, isPerson: boolean) => string,
    },
  };

  regexes: {
    [regexName: string]: RegExp,
  };

  constructor() {
    const guessCaseModeCookie = getCookie('guesscase_mode');
    this.modeName = isGuessCaseModeName(guessCaseModeCookie)
      ? guessCaseModeCookie
      : 'English';

    // Config
    this.CFG_KEEP_UPPERCASED =
      getCookie('guesscase_keepuppercase') !== 'false';

    // holder for the regular expressions
    this.regexes = {
      // define commonly used RE's
      SERIES_NUMBER: /^(\d+|[ivx]+)$/i,
      SPACES_DOTS: /\s|\./i,
    };

    this.entities = {
      area: {
        guess: this.guess('area', 'process'),
        sortname: this.guess('area', 'guessSortName'),
      },
      artist: {
        guess: this.guess('artist', 'process'),
        sortname: this.guess('artist', 'guessSortName'),
      },
      event: {
        guess: this.guess('event', 'process'),
        sortname: this.guess('event', 'guessSortName'),
      },
      genre: {
        guess: this.guess('genre', 'process'),
        sortname: this.guess('genre', 'guessSortName'),
      },
      instrument: {
        guess: this.guess('instrument', 'process'),
        sortname: this.guess('instrument', 'guessSortName'),
      },
      label: {
        guess: this.guess('label', 'process'),
        sortname: this.guess('label', 'guessSortName'),
      },
      place: {
        guess: this.guess('place', 'process'),
        sortname: this.guess('place', 'guessSortName'),
      },
      recording: {
        guess: this.guess('recording', 'process'),
        sortname: this.guess('recording', 'guessSortName'),
      },
      release: {
        guess: this.guess('release', 'process'),
        sortname: this.guess('release', 'guessSortName'),
      },
      release_group: {
        guess: this.guess('release_group', 'process'),
        sortname: this.guess('release_group', 'guessSortName'),
      },
      series: {
        guess: this.guess('series', 'process'),
        sortname: this.guess('series', 'guessSortName'),
      },
      track: {
        guess: this.guess('track', 'process'),
        sortname: this.guess('track', 'guessSortName'),
      },
      work: {
        guess: this.guess('work', 'process'),
        sortname: this.guess('work', 'guessSortName'),
      },
    };
  }

  // Member functions

  guess(
    handlerName: $Keys<typeof handlerPicker> | 'genre' | 'instrument',
    method: 'process' | 'guessSortName',
  ): (string) => string {
    if (handlerName === 'genre' || handlerName === 'instrument') {
      return ((inputString) => this.lowercaseEntityName(inputString));
    }

    let handler: GuessCaseHandler;

    /*
     * Guesses the name (e.g. capitalization) or sort name (for aliases)
     * of a given entity.
     * @param {string} is The unprocessed input string.
     * @return {string} The processed string.
     */
    return function (inputString: string): string {
      // Initialise flags for another run.
      flags.init();

      handler = handler || new handlerPicker[handlerName]();

      /*
       * We need to query the handler if the input string is
       * a special case, fetch the correct format, if the
       * returned case is indeed a special case.
       */
      const num = handler.checkSpecialCase(inputString);
      const output = handler.isSpecialCase(num)
        ? handler.getSpecialCaseFormatted(inputString, num)
        // if it was not a special case, start guessing
        // eslint-disable-next-line multiline-comment-style
        // $FlowIgnore[prop-missing]
        // $FlowIgnore[method-unbinding]
        : handler[method].apply(handler, arguments);

      return output;
    };
  }

  // For genres and instruments, all we need to do is lowercase the string
  lowercaseEntityName(name: string): string {
    return name.toLowerCase();
  }
}

export default (new GuessCase(): GuessCase);
