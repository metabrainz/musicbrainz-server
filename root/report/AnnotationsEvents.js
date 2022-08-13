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
import EventList from './components/EventList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import type {ReportDataT, ReportEventAnnotationT} from './types.js';

const AnnotationsEvents = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventAnnotationT>):
React.Element<typeof ReportLayout> => {
  const annotationColumns = useAnnotationColumns<ReportEventAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l('This report lists events with annotations.')}
      entityType="event"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l('Event annotations')}
      totalEntries={pager.total_entries}
    >
      <EventList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default AnnotationsEvents;
