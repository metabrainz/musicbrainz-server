/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ANNOTATION_REPORT_TEXT} from './constants';
import RecordingAnnotationList from './components/RecordingAnnotationList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingAnnotationT} from './types';

const AnnotationsRecordings = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingAnnotationT>):
React.Element<typeof ReportLayout> => (
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
    <RecordingAnnotationList items={items} pager={pager} />
  </ReportLayout>
);

export default AnnotationsRecordings;
