/*
 * @flow strict
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import doOrLogError from './doOrLogError.js';

/* eslint-disable import/no-mutable-exports */
export let hasLocalStorage: boolean = false;
export let hasSessionStorage: boolean = false;
/* eslint-enable import/no-mutable-exports */

// https://bugzilla.mozilla.org/show_bug.cgi?id=365772
try {
  hasLocalStorage = typeof window.localStorage === 'object' &&
    window.localStorage != null;
  hasSessionStorage = typeof window.sessionStorage === 'object' &&
    window.sessionStorage != null;
} catch (ignoredError) {
  // NOP
}

// Holds data where localStorage isn't supported
const store: {[name: string]: string, ...} = {};

export function localStorage(name: string, value?: string): string | void {
  if (arguments.length > 1) {
    if (value != null) {
      let inLocalStorage = false;
      if (hasLocalStorage) {
        try {
          window.localStorage.setItem(name, value);
          inLocalStorage = true;
        } catch (ignoredError) {
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
    } catch (ignoredError) {
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
}

/*
 * Some `sessionStorage` keys are intended to only store form data in case
 * of an error (so that state can be preserved). But if the form submits
 * succesfully, there's no easy way to tell the next page to delete those
 * keys. That could technically cause large amounts of form data to
 * accumulate if an editor is reusing the same session (tab) for editing.
 * Since `sessionStorage` space is limited, we want to delete such keys ASAP
 * (while still allowing access where they're needed).
 *
 * The current solution is to store a list of ephemeral key patterns that are
 * deleted whenever this module is loaded. Their values are moved into an
 * `ephemeralSessionStorageValues` map.
 */
const ephemeralSessionStorageKeys = [
  /^submittedLinks_/,
  /^relationshipEditorChanges_/,
];

const ephemeralSessionStorageValues = new Map<string, string>();

/*
 * We generally want to ignore errors such as "quota exceeded," which we
 * can't do anything about. (Exceeding the storage quota should be much
 * less likely now that MBS-13393 is mitigated.) Hence, all direct
 * `sessionStorage` access is wrapped in `doOrLogError`.
 */
export const sessionStorageWrapper: {
  get(key: string): ?string,
  remove(key: string): void,
  set(key: string, value: mixed): void,
} = hasSessionStorage
  ? {
    get(key) {
      return doOrLogError(
        () => {
          if (ephemeralSessionStorageValues.has(key)) {
            return ephemeralSessionStorageValues.get(key);
          }
          return sessionStorage.getItem(key);
        },
        /* captureToSentry = */ false,
      );
    },
    remove(key) {
      return doOrLogError(
        () => sessionStorage.removeItem(key),
        /* captureToSentry = */ false,
      );
    },
    set(key, value) {
      return doOrLogError(
        () => sessionStorage.setItem(key, String(value)),
        /* captureToSentry = */ false,
      );
    },
  }
  : {
    get() {},
    remove() {},
    set() {},
  };

if (hasSessionStorage) {
  doOrLogError(
    () => {
      for (const key of Object.keys(sessionStorage)) {
        if (ephemeralSessionStorageKeys.some(pattern => pattern.test(key))) {
          ephemeralSessionStorageValues.set(
            key,
            String(sessionStorage.getItem(key)),
          );
          sessionStorage.removeItem(key);
        }
      }
    },
    /* captureToSentry = */ true,
  );
}
