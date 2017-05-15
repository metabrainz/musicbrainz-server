// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const ko = require('knockout');

const {l} = require('../i18n');
const formatDate = require('./formatDate');

function formatDatePeriod(entity) {
  let {begin_date, end_date, ended} = entity;

  begin_date = formatDate(begin_date);
  end_date = formatDate(end_date);
  ended = ko.unwrap(ended);

  if (!begin_date && !end_date) {
    return ended ? l(' \u2013 ????') : '';
  }

  if (begin_date === end_date) {
    return begin_date;
  }

  if (begin_date && end_date) {
    return l('{begin_date} \u2013 {end_date}', {begin_date, end_date});
  }

  if (!begin_date) {
    return l('\u2013 {end_date}', {end_date});
  }

  if (!end_date) {
    return ended ? l('{begin_date} \u2013 ????', {begin_date}) : l('{begin_date} \u2013', {begin_date});
  }

  return '';
}

module.exports = formatDatePeriod;
