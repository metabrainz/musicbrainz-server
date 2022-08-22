/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingRelationshipT} from './types.js';

const DeprecatedRelationshipRecordings = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists recordings which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="recording"
    filtered={filtered}
    generated={generated}
    title={l('Recordings with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <RecordingList
      columnsBefore={[relTypeColumn]}
      items={items}
      pager={pager}
    />
  </ReportLayout>
);

export default DeprecatedRelationshipRecordings;
