/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import areDatesEqual from './areDatesEqual.js';
import {bracketedText} from './bracketed.js';
import formatDate from './formatDate.js';
import isDateEmpty from './isDateEmpty.js';

export default function relationshipDateText(
  r: $ReadOnly<{...DatePeriodRoleT, ...}>,
  bracketEnded?: boolean = true,
): string {
  if (!isDateEmpty(r.begin_date)) {
    if (!isDateEmpty(r.end_date)) {
      if (areDatesEqual(r.begin_date, r.end_date)) {
        // $FlowIssue[incompatible-use]
        if (r.begin_date.day != null) {
          return texp.l('on {date}', {date: formatDate(r.begin_date)});
        }
        return texp.l('in {date}', {date: formatDate(r.begin_date)});
      }
      return texp.l('from {begin_date} until {end_date}', {
        begin_date: formatDate(r.begin_date),
        end_date: formatDate(r.end_date),
      });
    } else if (r.ended) {
      return texp.l('from {date} to ????', {date: formatDate(r.begin_date)});
    }
    return texp.l('from {date} to present', {date: formatDate(r.begin_date)});
  } else if (!isDateEmpty(r.end_date)) {
    return texp.l('until {date}', {date: formatDate(r.end_date)});
  } else if (r.ended) {
    let text = l('ended');
    if (bracketEnded) {
      text = bracketedText(text);
    }
    return text;
  }
  return '';
}
