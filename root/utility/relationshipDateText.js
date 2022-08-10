/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {bracketedText} from '../static/scripts/common/utility/bracketed.js';
import formatDate from '../static/scripts/common/utility/formatDate.js';

import areDatesEqual from './areDatesEqual.js';

export default function relationshipDateText(
  r: $ReadOnly<{...DatePeriodRoleT, ...}>,
  bracketEnded?: boolean = true,
): string {
  if (r.begin_date) {
    if (r.end_date) {
      if (areDatesEqual(r.begin_date, r.end_date)) {
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
  } else if (r.end_date) {
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
