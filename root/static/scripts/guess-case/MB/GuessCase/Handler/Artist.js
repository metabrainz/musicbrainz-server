/*
 * @flow
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags';
import * as utils from '../../../utils';
import input from '../Input';
import gc from '../Main';
import output from '../Output';

import GuessCaseHandler from './Base';

// Artist specific GuessCase functionality
class GuessCaseArtistHandler extends GuessCaseHandler {
  /*
   * Checks special cases of artists
   * - empty, unknown -> [unknown]
   * - none, no artist, not applicable, n/a -> [no artist]
   */
  checkSpecialCase(inputString?: string): number {
    if (inputString) {
      if (!gc.regexes.ARTIST_EMPTY) {
        // Match empty
        gc.regexes.ARTIST_EMPTY = /^\s*$/i;
        // Match "unknown" and variants
        gc.regexes.ARTIST_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
        // Match "none" and variants
        gc.regexes.ARTIST_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
        // Match "no artist" and variants
        gc.regexes.ARTIST_NOARTIST = /^[\(\[]?\s*no[\s-]+artist\s*[\)\]]?$/i;
        // Match "not applicable" and variants
        gc.regexes.ARTIST_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
        // Match "n/a" and variants
        gc.regexes.ARTIST_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
      }
      if (inputString.match(gc.regexes.ARTIST_EMPTY)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.ARTIST_UNKNOWN)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.ARTIST_NONE)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.ARTIST_NOARTIST)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.ARTIST_NOTAPPLICABLE)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(gc.regexes.ARTIST_NA)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      }
    }
    return this.specialCaseValues.NOT_A_SPECIALCASE;
  }

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   */
  doWord(): boolean {
    output.appendSpaceIfNeeded();
    input.capitalizeCurrentWord();
    output.appendCurrentWord();

    flags.resetContext();
    flags.context.number = false;
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
    return true;
  }

  // Guesses the sortname for artists
  guessSortName(inputString: string, isPerson: boolean): string {
    return this.sortCompoundName(inputString, function (artist) {
      if (artist) {
        artist = utils.trim(artist);
        let append = '';

        // Strip Jr./Sr. from the string, and append at the end.
        if (!gc.regexes.SORTNAME_SR) {
          gc.regexes.SORTNAME_SR = /,\s*Sr[\.]?$/i;
          gc.regexes.SORTNAME_JR = /,\s*Jr[\.]?$/i;
        }

        if (artist.match(gc.regexes.SORTNAME_SR)) {
          artist = artist.replace(gc.regexes.SORTNAME_SR, '');
          append = ', Sr.';
        } else if (artist.match(gc.regexes.SORTNAME_JR)) {
          artist = artist.replace(gc.regexes.SORTNAME_JR, '');
          append = ', Jr.';
        }
        let names = artist.split(' ');

        /*
         * Handle some special cases, like DJ, The, Los which
         * are sorted at the end.
         */
        let reorder = false;
        if (!gc.regexes.SORTNAME_DJ) {
          gc.regexes.SORTNAME_DJ = /^DJ$/i; // match DJ
          gc.regexes.SORTNAME_THE = /^The$/i; // match The
          gc.regexes.SORTNAME_LOS = /^Los$/i; // match Los
          gc.regexes.SORTNAME_DR = /^Dr\.$/i; // match Dr.
        }
        const firstName = names[0];
        if (firstName.match(gc.regexes.SORTNAME_DJ)) {
          append = (', DJ' + append); // handle DJ xyz -> xyz, DJ
          names.shift();
        } else if (firstName.match(gc.regexes.SORTNAME_THE)) {
          append = (', The' + append); // handle The xyz -> xyz, The
          names.shift();
        } else if (firstName.match(gc.regexes.SORTNAME_LOS)) {
          append = (', Los' + append); // handle Los xyz -> xyz, Los
          names.shift();
        } else if (firstName.match(gc.regexes.SORTNAME_DR)) {
          append = (', Dr.' + append); // handle Dr. xyz -> xyz, Dr.
          names.shift();
          reorder = true; // reorder doctors.
        } else {
          reorder = true; // reorder by default
        }

        if (!isPerson) {
          reorder = false; // only reorder persons, not groups.
        }

        // we have to reorder the names
        if (reorder) {
          const reorderedNames = [];
          if (names.length > 1) {
            for (let i = 0; i < names.length - 1; i++) {
              // >> firstnames,middlenames one pos right
              if (i === names.length - 2 && names[i] === 'St.') {
                names[i + 1] = names[i] + ' ' + names[i + 1];
                /*
                 * Handle St. because it belongs
                 * to the lastname
                 */
              } else if (names[i]) {
                reorderedNames[i + 1] = names[i];
              }
            }
            reorderedNames[0] = names[names.length - 1]; // lastname,firstname
            if (reorderedNames.length > 1) {
              /*
               * Only append comma if there was more than 1
               * non-empty word (and therefore switched)
               */
              reorderedNames[0] += ',';
            }
            names = reorderedNames;
          }
        }

        return utils.trim(names.filter(Boolean).join(' ') + (append || ''));
      }

      return '';
    });
  }
}

export default GuessCaseArtistHandler;
