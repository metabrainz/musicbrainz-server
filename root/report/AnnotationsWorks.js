/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ANNOTATION_REPORT_TEXT} from './constants.js';
import WorkList from './components/WorkList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import type {ReportDataT, ReportWorkAnnotationT} from './types.js';

const AnnotationsWorks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkAnnotationT>):
React.Element<typeof ReportLayout> => {
  const annotationColumns = useAnnotationColumns<ReportWorkAnnotationT>();

  return (
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
      <WorkList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default AnnotationsWorks;
