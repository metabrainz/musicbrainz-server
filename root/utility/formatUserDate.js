// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import {trim} from 'lodash';
import moment from 'moment';

import 'moment-timezone';
import 'moment-strftime';

export default function formatUserDate(user, dateString, options) {
  let preferences = user.preferences;
  let result = moment(dateString);
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
