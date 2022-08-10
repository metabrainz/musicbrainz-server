/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const ShouldNotHaveDiscIds = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases that have at least one medium with a
       format that does not support disc IDs, yet have disc IDs attached.
       Usually this means the disc IDs ended up here because of a bug
       and should be moved or removed.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases that have disc IDs, but shouldn’t')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} subPath="discids" />
  </ReportLayout>
);

export default ShouldNotHaveDiscIds;
