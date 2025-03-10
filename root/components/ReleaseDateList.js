/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList.js';
import formatDate from '../static/scripts/common/utility/formatDate.js';

component ReleaseDateList(
  events as releaseEvents?: $ReadOnlyArray<ReleaseEventT>
) {
  if (!releaseEvents || !releaseEvents.length) {
    return null;
  }
  const dates = new Set<string>();
  for (const releaseEvent of releaseEvents) {
    const date = releaseEvent.date;
    const formattedDate = formatDate(date);
    if (nonEmpty(formattedDate)) {
      dates.add(formattedDate);
    }
  }
  return commaOnlyListText(Array.from(dates.values()));
}

export default ReleaseDateList;
