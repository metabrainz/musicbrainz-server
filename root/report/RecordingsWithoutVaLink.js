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

const RecordingsWithoutVaLink = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings with "Various Artists" as the
       credited name but not linked to the Various Artists entity.`,
    )}
    entityType="recording"
    filtered={filtered}
    generated={generated}
    title={l('Recordings credited to "Various Artists" but not linked to VA')}
    totalEntries={pager.total_entries}
  >
    <RecordingList items={items} pager={pager} />
  </ReportLayout>
);

export default RecordingsWithoutVaLink;
