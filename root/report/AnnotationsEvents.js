/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EventList from './components/EventList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportEventAnnotationT} from './types.js';

component AnnotationsEvents(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventAnnotationT>) {
  const annotationColumns = useAnnotationColumns<ReportEventAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports('This report lists events with annotations.')}
      entityType="event"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l_reports('Event annotations')}
      totalEntries={pager.total_entries}
    >
      <EventList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default AnnotationsEvents;
