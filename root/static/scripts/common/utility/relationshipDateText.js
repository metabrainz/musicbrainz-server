/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import areDatesEqual from './areDatesEqual.js';
import {bracketedText} from './bracketed.js';
import formatDate from './formatDate.js';
import {isDateNonEmpty} from './isDateEmpty.js';

export default function relationshipDateText(
  r: $ReadOnly<{...DatePeriodRoleT, ...}>,
  bracketEnded?: boolean = true,
): string {
  const beginDate = r.begin_date;
  const endDate = r.end_date;
  if (isDateNonEmpty(beginDate)) {
    if (isDateNonEmpty(endDate)) {
      if (areDatesEqual(beginDate, endDate)) {
        if (beginDate.day != null) {
          return texp.l('on {date}', {date: formatDate(beginDate)});
        }
        return texp.l('in {date}', {date: formatDate(beginDate)});
      }
      return texp.l('from {begin_date} until {end_date}', {
        begin_date: formatDate(beginDate),
        end_date: formatDate(endDate),
      });
    } else if (r.ended) {
      return texp.l('from {date} to ????', {date: formatDate(beginDate)});
    }
    return texp.l('from {date} to present', {date: formatDate(beginDate)});
  } else if (isDateNonEmpty(endDate)) {
    return texp.l('until {date}', {date: formatDate(endDate)});
  } else if (r.ended) {
    let text = l('ended');
    if (bracketEnded) {
      text = bracketedText(text);
    }
    return text;
  }
  return '';
}
