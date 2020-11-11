/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseT} from './types';

const ReleasesConflictingDiscIds = ({
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
    description={l(
      `This report shows releases that have conflicting disc IDs on the
       same medium with significant differences in duration. This usually
       means a disc ID was applied to the wrong medium or the wrong release.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with conflicting disc IDs')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} subPath="discids" />
  </ReportLayout>
);

export default ReleasesConflictingDiscIds;
