/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import areDatesEqual from './areDatesEqual.js';

export default function areDatePeriodsEqual<
  T: $ReadOnly<{...DatePeriodRoleT, ...}>,
>(a: T, b: T): boolean %checks {
  return (
    a.ended === b.ended &&
    areDatesEqual(a.begin_date, b.begin_date) &&
    areDatesEqual(a.end_date, b.end_date)
  );
}
