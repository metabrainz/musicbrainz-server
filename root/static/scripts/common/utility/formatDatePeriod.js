// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

/* There's also a formatDatePeriod function in
 * root/static/scripts/edit/utility/dates.js, which expects date objects
 * containing separate fields for the year, month, and day. Which is useful
 * for the parts of our UI where those fields are individually editable. This
 * function, on the other hand, expects an entity containing prerendered date
 * fields, i.e. our canonical JSON representation.
 */
function formatDatePeriod(entity) {
  let {begin_date, end_date, ended} = entity;

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
