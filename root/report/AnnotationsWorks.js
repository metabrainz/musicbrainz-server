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
import WorkAnnotationList from './components/WorkAnnotationList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportWorkAnnotationT} from './types';

const AnnotationsWorks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkAnnotationT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l('This report lists works with annotations.')}
    entityType="work"
    extraInfo={ANNOTATION_REPORT_TEXT()}
    filtered={filtered}
    generated={generated}
    title={l('Work annotations')}
    totalEntries={pager.total_entries}
  >
    <WorkAnnotationList items={items} pager={pager} />
  </ReportLayout>
);

export default AnnotationsWorks;
