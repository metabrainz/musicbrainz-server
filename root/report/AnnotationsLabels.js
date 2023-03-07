/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelList from './components/LabelList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportLabelAnnotationT} from './types.js';

const AnnotationsLabels = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelAnnotationT>):
React$Element<typeof ReportLayout> => {
  const annotationColumns = useAnnotationColumns<ReportLabelAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l('This report lists labels with annotations.')}
      entityType="label"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l('Label annotations')}
      totalEntries={pager.total_entries}
    >
      <LabelList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default AnnotationsLabels;
