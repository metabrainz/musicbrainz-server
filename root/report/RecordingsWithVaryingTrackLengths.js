/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

const RecordingsWithVaryingTrackLengths = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings where the linked tracks
       have times that vary by more than 30 seconds.`,
    )}
    entityType="recording"
    filtered={filtered}
    generated={generated}
    title={l('Recordings with varying track times')}
    totalEntries={pager.total_entries}
  >
    <RecordingList items={items} pager={pager} />
  </ReportLayout>
);

export default RecordingsWithVaryingTrackLengths;
