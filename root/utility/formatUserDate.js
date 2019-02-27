/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import moment from 'moment';
import trim from 'lodash/trim';

import 'moment-strftime';
import 'moment-timezone';

function formatUserDate(
  user: ?(CatalystUserT | SanitizedEditorT),
  dateString: string,
  options?: {dateOnly?: boolean},
) {
  const preferences = user ? user.preferences : null;
  const result = moment(dateString, moment.defaultFormat, true);
  let format = '%Y-%m-%d %H:%M %Z';

  if (preferences) {
    result.tz(preferences.timezone);
    format = preferences.datetime_format;
  }

  if (options && options.dateOnly) {
    format = format.replace('%c', '%x');
    format = format.replace(/%H:%M(:%S)?/, '');
    format = format.replace('%Z', '');
    format = format.replace(/,\s*$/, '');
    format = trim(format);
  }

  return result.strftime(format);
}

export default formatUserDate;
