/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportRecordingAnnotationT} from './types.js';

const AnnotationsRecordings = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingAnnotationT>):
React.Element<typeof ReportLayout> => {
  const annotationColumns =
    useAnnotationColumns<ReportRecordingAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l('This report lists recordings with annotations.')}
      entityType="recording"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l('Recording annotations')}
      totalEntries={pager.total_entries}
    >
      <RecordingList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default AnnotationsRecordings;
