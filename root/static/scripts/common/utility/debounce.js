/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

export default function debounce(func, ms = 100) {
  let timeoutId = null;
  return (...args) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      timeoutId = null;
      func(...args);
    }, ms);
  };
}

export function debounceComputed(value, delay) {
  if (!ko.isObservable(value)) {
    value = ko.computed(value);
  }
  if (
    typeof MUSICBRAINZ_RUNNING_TESTS !== 'undefined' &&
    MUSICBRAINZ_RUNNING_TESTS
  ) {
    return value;
  }
  return value.extend({
    rateLimit: {method: 'notifyWhenChangesStop', timeout: delay || 500},
  });
}
