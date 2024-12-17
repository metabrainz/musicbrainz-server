/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags.js';
import trim from '../../../utils/trim.js';

import GuessCaseHandler from './Base.js';

// Artist specific GuessCase functionality
class GuessCaseArtistHandler extends GuessCaseHandler {
  /*
   * Checks special cases of artists
   * - empty, unknown -> [unknown]
   * - none, no artist, not applicable, n/a -> [no artist]
   */
  checkSpecialCase(inputString?: string): number {
    if (inputString != null) {
      if (!this.regexes.ARTIST_EMPTY) {
        // Match empty
        this.regexes.ARTIST_EMPTY = /^\s*$/i;
        // Match "unknown" and variants
        this.regexes.ARTIST_UNKNOWN = /^[([]?\s*Unknown\s*[)\]]?$/i;
        // Match "none" and variants
        this.regexes.ARTIST_NONE = /^[([]?\s*none\s*[)\]]?$/i;
        // Match "no artist" and variants
        this.regexes.ARTIST_NOARTIST = /^[([]?\s*no[\s-]+artist\s*[)\]]?$/i;
        // Match "not applicable" and variants
        this.regexes.ARTIST_NOTAPPLICABLE = /^[([]?\s*not[\s-]+applicable\s*[)\]]?$/i;
        // Match "n/a" and variants
        this.regexes.ARTIST_NA = /^[([]?\s*n\s*[\\/]\s*a\s*[)\]]?$/i;
      }
      if (inputString.match(this.regexes.ARTIST_EMPTY)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.ARTIST_UNKNOWN)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.ARTIST_NONE)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.ARTIST_NOARTIST)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.ARTIST_NOTAPPLICABLE)) {
        return this.specialCaseValues.SPECIALCASE_UNKNOWN;
      } else if (inputString.match(this.regexes.ARTIST_NA)) {
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
    this.output.appendSpaceIfNeeded();
    this.input.capitalizeCurrentWord();
    this.output.appendCurrentWord();

    flags.resetContext();
    flags.context.number = false;
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
    return true;
  }

  // Guesses the sortname for artists
  guessSortName(inputString: string, isPerson: boolean): string {
    return this.sortCompoundName(inputString, function (artistName, regexes) {
      if (artistName) {
        let modifiedArtistName = trim(artistName);
        let append = '';

        // Strip Jr./Sr. from the string, and append at the end.
        if (!regexes.SORTNAME_SR) {
          regexes.SORTNAME_SR = /,\s*Sr\.?$/i;
          regexes.SORTNAME_JR = /,\s*Jr\.?$/i;
        }

        if (modifiedArtistName.match(regexes.SORTNAME_SR)) {
          modifiedArtistName =
            modifiedArtistName.replace(regexes.SORTNAME_SR, '');
          append = ', Sr.';
        } else if (modifiedArtistName.match(regexes.SORTNAME_JR)) {
          modifiedArtistName =
            modifiedArtistName.replace(regexes.SORTNAME_JR, '');
          append = ', Jr.';
        }
        let names = modifiedArtistName.split(' ');

        /*
         * Handle some special cases, like DJ, The, Los which
         * are sorted at the end.
         */
        let reorder = false;
        if (!regexes.SORTNAME_DJ) {
          regexes.SORTNAME_DJ = /^DJ$/i; // match DJ
          regexes.SORTNAME_THE = /^The$/i; // match The
          regexes.SORTNAME_LOS = /^Los$/i; // match Los
          regexes.SORTNAME_DR = /^Dr\.$/i; // match Dr.
        }
        const firstName = names[0];
        if (firstName.match(regexes.SORTNAME_DJ)) {
          append = (', DJ' + append); // handle DJ xyz -> xyz, DJ
          names.shift();
        } else if (firstName.match(regexes.SORTNAME_THE)) {
          append = (', The' + append); // handle The xyz -> xyz, The
          names.shift();
        } else if (firstName.match(regexes.SORTNAME_LOS)) {
          append = (', Los' + append); // handle Los xyz -> xyz, Los
          names.shift();
        } else if (firstName.match(regexes.SORTNAME_DR)) {
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

        return trim(names.filter(Boolean).join(' ') + (append || ''));
      }

      return '';
    });
  }
}

export default GuessCaseArtistHandler;
