/* Copyright (C) 2009 Oliver Charles

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

// Namespaces
var MB = {
    // Classes, common controls used throughout MusicBrainz
    Control: {},

    // Utility functions
    utility: {},

    // Hold translated text strings
    text: {},

    // Hold constants
    constants: {}
};

MB.constants.VARTIST_ID = 1;
MB.constants.VARTIST_GID = '89ad4ac3-39f7-470e-963a-56509c546377';
MB.constants.VARTIST_NAME = 'Various Artists';

MB.constants.ENTITIES = [ 'artist', 'editor', 'instrument', 'label', 'release', 'release-group', 'recording', 'work', 'area', 'place' ];

MB.constants.MAX_LENGTH_DIFFERENCE = 10500;
MB.constants.MIN_NAME_SIMILARITY = 0.75;
