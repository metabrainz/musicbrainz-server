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
import PlaceAnnotationList from './components/PlaceAnnotationList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportPlaceAnnotationT} from './types';

const AnnotationsPlaces = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportPlaceAnnotationT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l('This report lists places with annotations.')}
    entityType="place"
    extraInfo={ANNOTATION_REPORT_TEXT()}
    filtered={filtered}
    generated={generated}
    title={l('Place annotations')}
    totalEntries={pager.total_entries}
  >
    <PlaceAnnotationList items={items} pager={pager} />
  </ReportLayout>
);

export default AnnotationsPlaces;
