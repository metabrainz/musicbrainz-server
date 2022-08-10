/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isGreyedOut from '../url/utility/isGreyedOut.js';
import isFutureDate from '../utility/isFutureDate.js';

export default function isDisabledLink(
  relationshipOrLinkDatePeriod: {
    +end_date: PartialDateT | null,
    +ended: boolean,
    ...
  },
  entity: CoreEntityT,
): boolean {
  const isEnded = relationshipOrLinkDatePeriod.ended &&
                  !isFutureDate(relationshipOrLinkDatePeriod.end_date);

  return entity.entityType === 'url' && (
    isEnded || isGreyedOut(entity.href_url)
  );
}
