/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../static/scripts/common/i18n.js';
import compareDates from '../static/scripts/common/utility/compareDates.js';
import getSortName from '../static/scripts/common/utility/getSortName.js';

export default function compareRelationships(
  a: RelationshipT,
  b: RelationshipT,
): number {
  let result = (
    (a.linkTypeID - b.linkTypeID) ||
    (a.linkOrder - b.linkOrder) ||
    compareDates(a.begin_date, b.begin_date) ||
    compareDates(a.end_date, b.end_date)
  );
  if (!result) {
    const targetA = a.target;
    const targetB = b.target;
    result = compare(getSortName(targetA), getSortName(targetB));
  }
  return result;
}
