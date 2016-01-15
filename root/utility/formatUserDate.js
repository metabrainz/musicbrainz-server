// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {trim} = require('lodash');
const moment = require('moment');

require('moment-strftime');
require('moment-timezone');

function formatUserDate(user, dateString, options) {
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

module.exports = formatUserDate;
