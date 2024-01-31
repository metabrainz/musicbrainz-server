/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatDate from './formatDate.js';
import isDateEmpty from './isDateEmpty.js';

export default function formatEndDate<T: $ReadOnly<{
  ...DatePeriodRoleT,
  ...
}>>(entity: T): null | string {
  return isDateEmpty(entity.end_date)
    ? (entity.ended ? lp('[unknown]', 'date') : null)
    : formatDate(entity.end_date);
}
