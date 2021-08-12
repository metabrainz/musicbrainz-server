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
import * as utils from '../../../utils';
import input from '../Input';
import output from '../Output';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

// Artist specific GuessCase functionality
MB.GuessCase.Handler.Artist = function (gc) {
  var self = MB.GuessCase.Handler.Base(gc);

  /*
   * Checks special cases of artists
   * - empty, unknown -> [unknown]
   * - none, no artist, not applicable, n/a -> [no artist]
   */
  self.checkSpecialCase = function (is) {
    if (is) {
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
      if (is.match(gc.regexes.ARTIST_EMPTY)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.ARTIST_UNKNOWN)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.ARTIST_NONE)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.ARTIST_NOARTIST)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.ARTIST_NOTAPPLICABLE)) {
        return self.SPECIALCASE_UNKNOWN;
      } else if (is.match(gc.regexes.ARTIST_NA)) {
        return self.SPECIALCASE_UNKNOWN;
      }
    }
    return self.NOT_A_SPECIALCASE;
  };

  /*
   * Delegate function which handles words not handled
   * in the common word handlers.
   */
  self.doWord = function () {
    output.appendSpaceIfNeeded();
    input.capitalizeCurrentWord();
    output.appendCurrentWord();

    flags.resetContext();
    flags.context.number = false;
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
    return null;
  };

  // Guesses the sortname for artists
  self.guessSortName = function (is, person) {
    return self.sortCompoundName(is, function (artist) {
      if (artist) {
        artist = utils.trim(artist);
        var append = '';

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
        var names = artist.split(' ');

        /*
         * Handle some special cases, like DJ, The, Los which
         * are sorted at the end.
         */
        var reorder = false;
        if (!gc.regexes.SORTNAME_DJ) {
          gc.regexes.SORTNAME_DJ = /^DJ$/i; // match DJ
          gc.regexes.SORTNAME_THE = /^The$/i; // match The
          gc.regexes.SORTNAME_LOS = /^Los$/i; // match Los
          gc.regexes.SORTNAME_DR = /^Dr\.$/i; // match Dr.
        }
        var firstName = names[0];
        if (firstName.match(gc.regexes.SORTNAME_DJ)) {
          append = (', DJ' + append); // handle DJ xyz -> xyz, DJ
          names[0] = null;
        } else if (firstName.match(gc.regexes.SORTNAME_THE)) {
          append = (', The' + append); // handle The xyz -> xyz, The
          names[0] = null;
        } else if (firstName.match(gc.regexes.SORTNAME_LOS)) {
          append = (', Los' + append); // handle Los xyz -> xyz, Los
          names[0] = null;
        } else if (firstName.match(gc.regexes.SORTNAME_DR)) {
          append = (', Dr.' + append); // handle Dr. xyz -> xyz, Dr.
          names[0] = null;
          reorder = true; // reorder doctors.
        } else {
          reorder = true; // reorder by default
        }

        if (!person) {
          reorder = false; // only reorder persons, not groups.
        }

        // we have to reorder the names
        var i = 0;
        if (reorder) {
          var reOrderedNames = [];
          if (names.length > 1) {
            for (i = 0; i < names.length - 1; i++) {
              // >> firstnames,middlenames one pos right
              if (i == names.length - 2 && names[i] == 'St.') {
                names[i + 1] = names[i] + ' ' + names[i + 1];
                /*
                 * Handle St. because it belongs
                 * to the lastname
                 */
              } else if (names[i]) {
                reOrderedNames[i + 1] = names[i];
              }
            }
            reOrderedNames[0] = names[names.length - 1]; // lastname,firstname
            if (reOrderedNames.length > 1) {
              /*
               * Only append comma if there was more than 1
               * non-empty word (and therefore switched)
               */
              reOrderedNames[0] += ',';
            }
            names = reOrderedNames;
          }
        }

        return utils.trim(names.filter(Boolean).join(' ') + (append || ''));
      }

      return '';
    });
  };

  return self;
};
