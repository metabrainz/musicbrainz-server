/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (c) 2005 Stefan Kestenholz (keschte)
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

const flags = require('../../../flags');

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/**
 * Release specific GuessCase functionality
 **/
MB.GuessCase.Handler.Release = function () {
    var self = MB.GuessCase.Handler.Base();

    /**
     * Checks special cases of releases
     **/
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.RELEASE_UNTITLED) {
                // untitled
                gc.re.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
            }
            if (is.match(gc.re.RELEASE_UNTITLED)) {
                return self.SPECIALCASE_UNTITLED;
            }
        }
        return self.NOT_A_SPECIALCASE;
    };

    /**
     * Guess the releasename given in string is, and
     * returns the guessed name.
     *
     * @param    is        the inputstring
     * @returns os        the processed string
     **/
    self.process = _.wrap(self.process, function (process, os) {
        return gc.mode.fixVinylSizes(process(os));
    });

    self.getWordsForProcessing = function (is) {
        is = gc.mode.preProcessTitles(is);
        return gc.mode.prepExtraTitleInfo(gc.i.splitWordsAndPunctuation(is));
    };

    /**
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
     * - Handles FeaturingArtistStyle
     *
     **/
    self.doWord = function () {
        if (self.doFeaturingArtistStyle()) {
        } else if (gc.mode.doWord()) {
        } else {
            self.doNormalWord();
        }
        flags.context.number = false;
        return null;
    };

    return self;
};
