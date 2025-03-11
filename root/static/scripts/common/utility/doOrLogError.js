/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {captureException} from '@sentry/browser';

export default function doOrLogError<T>(
  callback: () => T,
  captureToSentry?: boolean = true,
): T | void {
  try {
    return callback();
  } catch (error) {
    console.error(error);
    if (captureToSentry) {
      captureException(error);
    }
  }
  return undefined;
}
