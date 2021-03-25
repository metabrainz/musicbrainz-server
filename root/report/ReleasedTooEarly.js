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

const ReleasedTooEarly = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases which have disc IDs even though they
       were released too early to have disc IDs, where one of the medium
       formats didn't exist at the time the release was released or
       where a disc ID is attached to a medium whose format does not
       have disc IDs.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases released too early')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default ReleasedTooEarly;
