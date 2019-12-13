/*
 * @flow
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import formatDate from './formatDate';

function formatDatePeriod<+T: {...DatePeriodRoleT, ...}>(entity: T) {
  let {begin_date: beginDate, end_date: endDate, ended} = entity;

  beginDate = formatDate(beginDate);
  endDate = formatDate(endDate);
  ended = (ko.unwrap(ended): boolean);

  if (!beginDate && !endDate) {
    return ended ? l(' \u2013 ????') : '';
  }

  if (beginDate === endDate) {
    return beginDate;
  }

  if (beginDate && endDate) {
    return texp.l('{begin_date} \u2013 {end_date}', {begin_date: beginDate, end_date: endDate});
  }

  if (!beginDate) {
    return texp.l('\u2013 {end_date}', {end_date: endDate});
  }

  if (!endDate) {
    return ended
      ? texp.l('{begin_date} \u2013 ????', {begin_date: beginDate})
      : texp.l('{begin_date} \u2013', {begin_date: beginDate});
  }

  return '';
}

export default formatDatePeriod;
