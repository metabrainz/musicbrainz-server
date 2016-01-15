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

const global = require('../global');

// Namespaces
global.MB = {
    // Classes, common controls used throughout MusicBrainz
    Control: {},

    // Utility functions
    utility: {},

    // Hold translated text strings
    text: {},

    // Holds data where localStorage isn't supported
    store: {},

    // Deprecated reference needed by knockout templates
    i18n: require('./i18n')
};

// https://bugzilla.mozilla.org/show_bug.cgi?id=365772
try {
    MB.hasLocalStorage = !!window.localStorage;
    MB.hasSessionStorage = !!window.sessionStorage;
} catch (e) {
    MB.hasLocalStorage = false;
    MB.hasSessionStorage = false;
}

MB.localStorage = function (name, value) {
    if (arguments.length > 1) {
        var inLocalStorage = false;

        if (MB.hasLocalStorage) {
            try {
                window.localStorage.setItem(name, value);
                inLocalStorage = true;
            } catch (e) {
                // NS_ERROR_DOM_QUOTA_REACHED
                // NS_ERROR_FILE_NO_DEVICE_SPACE
            }
        }
        if (!inLocalStorage) {
            MB.store[name] = value;
        }
    } else {
        var storedValue;

        if (MB.hasLocalStorage) {
            try {
                storedValue = window.localStorage.getItem(name);
            } catch (e) {
                // NS_ERROR_FILE_CORRUPTED?
            }

            // localStorage.hasOwnProperty doesn't exist in IE8 and is outright
            // broken in Opera (at least the Presto versions). Source:
            // https://shanetomlinson.com/2012/localstorage-bugs-inconsistent-removeitem-delete/

            if (storedValue !== undefined) {
                return storedValue;
            }
        }
        return MB.store[name];
    }
};
