/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from './components/RecordingList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingT} from './types';

const RecordingsWithEarliestReleaseRelationships = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings that have the deprecated "earliest
       release" relationship. They should be merged if they are truly
       the same recording; if they're not, the relationship should be
       removed. Please, do not merge recordings blindly just because
       the lengths fit, and do not merge recordings with very different
       times!`,
    )}
    entityType="recording"
    filtered={filtered}
    generated={generated}
    title={l('Recordings with earliest release relationships')}
    totalEntries={pager.total_entries}
  >
    <RecordingList items={items} pager={pager} />
  </ReportLayout>
);

export default RecordingsWithEarliestReleaseRelationships;
