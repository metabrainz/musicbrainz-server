/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

let nextAvailableTime = new Date().getTime();
let previousDeferred = null;
const timeout = 1000;

function makeRequest(args, context, deferred) {
  deferred.jqXHR = $.ajax({dataType: 'json', ...args})
    .done(function () {
      if (!deferred.aborted) {
        deferred.resolveWith(context, arguments);
      }
    })
    .fail(function () {
      if (!deferred.aborted) {
        deferred.rejectWith(context, arguments);
      }
    });

  deferred.jqXHR.sentData = args.data;
}

function request(args, context) {
  const deferred = $.Deferred();
  const now = new Date().getTime();
  let later;

  if (nextAvailableTime - now <= 0) {
    makeRequest(args, context, deferred);

    // nextAvailableTime is in the past.
    nextAvailableTime = now + timeout;
  } else {
    later = function () {
      if (!deferred.aborted && !deferred.complete) {
        makeRequest(args, context, deferred);
      } else if (deferred.next) {
        deferred.next();
      }
      deferred.complete = true;
    };

    if (previousDeferred) {
      previousDeferred.next = later;
    }
    previousDeferred = deferred;

    setTimeout(later, nextAvailableTime - now);

    // nextAvailableTime is in the future.
    nextAvailableTime += timeout;
  }

  const promise = deferred.promise();

  promise.abort = function () {
    if (deferred.jqXHR) {
      deferred.jqXHR.abort();
    } else {
      deferred.aborted = true;
    }
  };

  return promise;
}

export default request;
