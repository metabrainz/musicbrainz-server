/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatDate from './formatDate';

export default function formatEndDate<+T: $ReadOnly<{
  ...DatePeriodRoleT,
  ...,
}>>(entity: T) {
  return entity.end_date
    ? formatDate(entity.end_date)
    : entity.ended ? l('[unknown]') : null;
}
