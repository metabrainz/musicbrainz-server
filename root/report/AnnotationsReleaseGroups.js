/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseGroupList from './components/ReleaseGroupList.js';
import ReportLayout from './components/ReportLayout.js';
import useAnnotationColumns from './hooks/useAnnotationColumns.js';
import {ANNOTATION_REPORT_TEXT} from './constants.js';
import type {ReportDataT, ReportReleaseGroupAnnotationT} from './types.js';

const AnnotationsReleaseGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupAnnotationT>):
React.Element<typeof ReportLayout> => {
  const annotationColumns =
    useAnnotationColumns<ReportReleaseGroupAnnotationT>();

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l('This report lists release groups with annotations.')}
      entityType="release_group"
      extraInfo={ANNOTATION_REPORT_TEXT()}
      filtered={filtered}
      generated={generated}
      title={l('Release group annotations')}
      totalEntries={pager.total_entries}
    >
      <ReleaseGroupList
        columnsAfter={annotationColumns}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default AnnotationsReleaseGroups;
