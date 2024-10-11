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
import isGuessCaseModeName from '../../utils/isGuessCaseModeName.js';

import GuessCaseAreaHandler from './Handler/Area.js';
import GuessCaseArtistHandler from './Handler/Artist.js';
import GuessCaseLabelHandler from './Handler/Label.js';
import GuessCasePlaceHandler from './Handler/Place.js';
import GuessCaseReleaseHandler from './Handler/Release.js';
import GuessCaseTrackHandler from './Handler/Track.js';
import GuessCaseWorkHandler from './Handler/Work.js';
import GuessCaseInput from './Input.js';
import GuessCaseOutput from './Output.js';

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
        guess: this.guess('area', 'process', this.regexes),
        sortname: this.guess('area', 'guessSortName', this.regexes),
      },
      artist: {
        guess: this.guess('artist', 'process', this.regexes),
        sortname: this.guess('artist', 'guessSortName', this.regexes),
      },
      event: {
        guess: this.guess('event', 'process', this.regexes),
        sortname: this.guess('event', 'guessSortName', this.regexes),
      },
      genre: {
        guess: this.guess('genre', 'process', this.regexes),
        sortname: this.guess('genre', 'guessSortName', this.regexes),
      },
      instrument: {
        guess: this.guess('instrument', 'process', this.regexes),
        sortname: this.guess('instrument', 'guessSortName', this.regexes),
      },
      label: {
        guess: this.guess('label', 'process', this.regexes),
        sortname: this.guess('label', 'guessSortName', this.regexes),
      },
      place: {
        guess: this.guess('place', 'process', this.regexes),
        sortname: this.guess('place', 'guessSortName', this.regexes),
      },
      recording: {
        guess: this.guess('recording', 'process', this.regexes),
        sortname: this.guess('recording', 'guessSortName', this.regexes),
      },
      release: {
        guess: this.guess('release', 'process', this.regexes),
        sortname: this.guess('release', 'guessSortName', this.regexes),
      },
      release_group: {
        guess: this.guess('release_group', 'process', this.regexes),
        sortname: this.guess('release_group', 'guessSortName', this.regexes),
      },
      series: {
        guess: this.guess('series', 'process', this.regexes),
        sortname: this.guess('series', 'guessSortName', this.regexes),
      },
      track: {
        guess: this.guess('track', 'process', this.regexes),
        sortname: this.guess('track', 'guessSortName', this.regexes),
      },
      work: {
        guess: this.guess('work', 'process', this.regexes),
        sortname: this.guess('work', 'guessSortName', this.regexes),
      },
    };
  }

  // Member functions

  guess(
    handlerName: $Keys<typeof handlerPicker> | 'genre' | 'instrument',
    method: 'process' | 'guessSortName',
    regexes: {[regexName: string]: RegExp},
  ): (string) => string {
    if (handlerName === 'genre' || handlerName === 'instrument') {
      return ((inputString) => this.lowercaseEntityName(inputString));
    }

    /*
     * Guesses the name (e.g. capitalization) or sort name (for aliases)
     * of a given entity.
     * @param {string} is The unprocessed input string.
     * @return {string} The processed string.
     */
    return function (
      inputString: string,
      isPerson?: boolean = false,
    ): string {
      const guessCaseModeCookie = getCookie('guesscase_mode');
      const modeName = isGuessCaseModeName(guessCaseModeCookie)
        ? guessCaseModeCookie
        : 'English';

      const CFG_KEEP_UPPERCASED =
        getCookie('guesscase_keepuppercase') !== 'false';

      // Initialise flags for another run.
      flags.init();

      const input = new GuessCaseInput(
        inputString,
        modeName,
        CFG_KEEP_UPPERCASED,
        regexes,
      );

      const output = new GuessCaseOutput(
        input,
        modeName,
        CFG_KEEP_UPPERCASED,
      );

      const handler = new handlerPicker[handlerName](
        modeName,
        regexes,
        input,
        output,
      );

      /*
       * We need to query the handler if the input string is
       * a special case, fetch the correct format, if the
       * returned case is indeed a special case.
       */
      const num = handler.checkSpecialCase(inputString);
      let result;
      if (handler.isSpecialCase(num)) {
        result = handler.getSpecialCaseFormatted(inputString, num);
      } else if (handler instanceof GuessCaseArtistHandler &&
                 method === 'guessSortName') {
        result = handler[method](inputString, isPerson);
      } else {
        // $FlowIgnore[incompatible-call]
        result = handler[method](inputString);
      }

      return result;
    };
  }

  // For genres and instruments, all we need to do is lowercase the string
  lowercaseEntityName(name: string): string {
    return name.toLowerCase();
  }
}

export default (new GuessCase(): GuessCase);
