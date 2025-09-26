/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportReleaseAnnotationT} from './types.js';

component AnnotationsReleases(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseAnnotationT>) {
  const annotationColumns = useAnnotationColumns<ReportReleaseAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports('This report lists releases with annotations.')}
      entityType="release"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l_reports('Release annotations')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default AnnotationsReleases;
