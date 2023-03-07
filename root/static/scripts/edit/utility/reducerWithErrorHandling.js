/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';

import coerceToError from '../../common/utility/coerceToError.js';

/*
 * Wraps a reducer function, returning a new reducer that catches
 * any exceptions in the original. In that event, we log the exception
 * to Sentry and return the previous state back with a `reducerError`
 * set.
 */
export default function reducerWithErrorHandling<
  S: {+reducerError: Error | null, ...},
  -A,
>(
  reducer: (S, A) => S,
): (S, A) => S {
  return (state: S, action: A): S => {
    let error = null;
    try {
      return reducer(state, action);
    } catch (e) {
      error = coerceToError(e);
      if (
        !hasOwnProp(error, 'doNotLogToSentry') ||
        // $FlowIgnore[prop-missing]
        error.doNotLogToSentry !== true
      ) {
        Sentry.captureException(error);
      }
    }
    return {...state, reducerError: error};
  };
}
