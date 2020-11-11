/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseT} from './types';

const PartOfSetRelationships = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows releases that still have the deprecated "part
       of set" relationship and should probably be merged. For
       instructions on how to fix them, please see the documentation
       about {how_to_merge_releases|how to merge releases}. If the
       releases are not really part of a set (for example, if they are
       independently-released volumes in a series) just remove the
       relationship.`,
      {how_to_merge_releases: '/doc/How_to_Merge_Releases'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with “part of set” relationships')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default PartOfSetRelationships;
