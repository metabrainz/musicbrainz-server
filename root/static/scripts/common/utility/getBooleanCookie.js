// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const getCookie = require('./getCookie');

function getBooleanCookie(name, defaultValue = false) {
  let value = getCookie(name);

  if (value === '1' || value === 'true') {
    return true;
  }

  if (value === '0' || value === 'false') {
    return false;
  }

  return defaultValue;
}

module.exports = getBooleanCookie;
