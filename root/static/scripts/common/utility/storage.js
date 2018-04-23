/*
 * @flow
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

let hasLocalStorage = false;
let hasSessionStorage = false;

// https://bugzilla.mozilla.org/show_bug.cgi?id=365772
try {
  hasLocalStorage = !!window.localStorage;
  hasSessionStorage = !!window.sessionStorage;
} catch (e) {
  // NOP
}

// Holds data where localStorage isn't supported
const store: {[string]: string} = {};

function localStorage(name: string, value?: string): string | void {
  if (arguments.length > 1) {
    if (value) {
      let inLocalStorage = false;
      if (hasLocalStorage) {
        try {
          window.localStorage.setItem(name, value);
          inLocalStorage = true;
        } catch (e) {
          /*
           * NS_ERROR_DOM_QUOTA_REACHED
           * NS_ERROR_FILE_NO_DEVICE_SPACE
           */
        }
      }
      if (!inLocalStorage) {
        store[name] = value;
      }
    }
    return undefined;
  }

  if (hasLocalStorage) {
    let storedValue;
    try {
      storedValue = window.localStorage.getItem(name);
    } catch (e) {
      // NS_ERROR_FILE_CORRUPTED?
    }
    /*
     * localStorage.hasOwnProperty doesn't exist in IE8 and is outright
     * broken in Opera (at least the Presto versions). Source:
     * https://shanetomlinson.com/2012/localstorage-bugs-inconsistent-removeitem-delete/
     */
    if (storedValue !== undefined) {
      return storedValue;
    }
  }
  return store[name];
};

exports.hasLocalStorage = hasLocalStorage;
exports.hasSessionStorage = hasSessionStorage;
exports.localStorage = localStorage;
