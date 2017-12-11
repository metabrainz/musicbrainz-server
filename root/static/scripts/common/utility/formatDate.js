// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014-2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const ko = require('knockout');
const {padStart} = require('lodash');

const nonEmpty = require('./nonEmpty');

function formatDate(date) {
  if (date == null) {
    return '';
  }

  const y = ko.unwrap(date.year);
  const m = ko.unwrap(date.month);
  const d = ko.unwrap(date.day);

  let result = '';

  if (nonEmpty(y)) {
    if (y < 0) {
      result += '-' + padStart(-y, 3, '0');
    } else {
      result += padStart(y, 4, '0');
    }
  } else if (m || d) {
    result = '????';
  }

  if (m) {
    result += '-' + padStart(m, 2, '0');
  } else if (d) {
    result += '-??';
  }

  if (d) {
    result += '-' + padStart(d, 2, '0');
  }

  return result;
}

module.exports = formatDate;
