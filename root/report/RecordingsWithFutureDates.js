/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  defineTextColumn,
  relTypeColumn,
} from '../utility/tableColumns.js';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingRelationshipT} from './types.js';

component RecordingsWithFutureDates(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingRelationshipT>) {
  const extraColumns = React.useMemo(
    () => {
      const beginDateColumn = defineTextColumn<ReportRecordingRelationshipT>({
        columnName: 'begin_date',
        getText: result => result.begin?.toString() ?? '',
        title: l_mb_server('Begin date'),
      });
      const endDateColumn = defineTextColumn<ReportRecordingRelationshipT>({
        columnName: 'end_date',
        getText: result => result.end?.toString() ?? '',
        title: l_mb_server('End date'),
      });

      return [
        beginDateColumn,
        endDateColumn,
        relTypeColumn,
      ];
    },
    [],
  );

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows recordings with relationships using dates in
        the future. Those are probably typos (such as 2109 instead of 2019).`,
      )}
      entityType="relationship"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Recordings with relationships having dates in the future',
      )}
      totalEntries={pager.total_entries}
    >
      <RecordingList
        columnsBefore={extraColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default RecordingsWithFutureDates;
