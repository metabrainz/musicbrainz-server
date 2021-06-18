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
import LabelList from './components/LabelList';
import ReportLayout from './components/ReportLayout';
import useAnnotationColumns from './hooks/useAnnotationColumns';
import type {ReportDataT, ReportLabelAnnotationT} from './types';

const AnnotationsLabels = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelAnnotationT>):
React.Element<typeof ReportLayout> => {
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
