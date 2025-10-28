/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReportLayout from './components/ReportLayout.js';
import SeriesList from './components/SeriesList.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportSeriesAnnotationT} from './types.js';

component AnnotationsSeries(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportSeriesAnnotationT>) {
  const annotationColumns = useAnnotationColumns<ReportSeriesAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports('This report lists series with annotations.')}
      entityType="series"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l_reports('Series annotations')}
      totalEntries={pager.total_entries}
    >
      <SeriesList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default AnnotationsSeries;
