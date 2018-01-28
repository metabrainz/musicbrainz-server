/* @flow
   Copyright (C) 2009 Oliver Charles

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

'use strict';

import * as constants from './constants';

const global = require('../global');

// Namespaces
const MB: {[string]: *} = {
    // Classes, common controls used throughout MusicBrainz
    Control: {},

    // Utility functions
    utility: {},

    // Hold translated text strings
    text: {},

    // Hold constants for knockout templates that depend on globals.
    constants,

    // Deprecated reference needed by knockout templates
    i18n: require('./i18n')
};

global.MB = MB;

module.exports = MB;
