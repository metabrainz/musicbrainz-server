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
import ReleaseAnnotationList from './components/ReleaseAnnotationList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseAnnotationT} from './types';

const AnnotationsReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseAnnotationT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l('This report lists releases with annotations.')}
    entityType="release"
    extraInfo={ANNOTATION_REPORT_TEXT()}
    filtered={filtered}
    generated={generated}
    title={l('Release annotations')}
    totalEntries={pager.total_entries}
  >
    <ReleaseAnnotationList items={items} pager={pager} />
  </ReportLayout>
);

export default AnnotationsReleases;
