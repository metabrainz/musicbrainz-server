/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../static/scripts/common/i18n';
import compareDates from '../static/scripts/common/utility/compareDates';

export default function compareRelationships(
  a: RelationshipT,
  b: RelationshipT,
): number {
  return (
    (a.linkTypeID - b.linkTypeID) ||
    (a.linkOrder - b.linkOrder) ||
    compareDates(a.begin_date, b.begin_date) ||
    compareDates(a.end_date, b.end_date) ||
    compare(a.target.sort_name || a.target.name,
            b.target.sort_name || b.target.name)
  );
}
