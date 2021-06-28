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
  defineTextColumn,
} from '../utility/tableColumns';

import RecordingList from './components/RecordingList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingTrackT} from './types';

const RecordingTrackDifferentName = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingTrackT>):
React.Element<typeof ReportLayout> => {
  const trackColumn = defineTextColumn<ReportRecordingTrackT>({
    columnName: 'track',
    getText: result => result.track_name,
    title: l('Track'),
  });

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows recordings that are linked to only one track,
         yet have a different name than the track. This might mean
         one of the two needs to be renamed to match the other.`,
      )}
      entityType="recording"
      filtered={filtered}
      generated={generated}
      title={l('Recordings with a different name than their only track')}
      totalEntries={pager.total_entries}
    >
      <RecordingList
        columnsBefore={[trackColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default RecordingTrackDifferentName;
