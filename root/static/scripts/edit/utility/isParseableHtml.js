/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {state as expand2State} from '../../common/i18n/expand2.js';
import expand2react from '../../common/i18n/expand2react.js';

export default function isParseableHtml(text: string): string {
  if (empty(text)) {
    return '';
  }

  expand2react(text);
  // If not parseable, an error will have been saved in state
  const error = expand2State.error;
  if (nonEmpty(error)) {
    return error;
  }

  return '';
}
