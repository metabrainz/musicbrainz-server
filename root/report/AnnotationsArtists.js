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
import ArtistAnnotationList from './components/ArtistAnnotationList';
import ReportLayout from './components/ReportLayout';
import type {ReportArtistAnnotationT, ReportDataT} from './types';

const AnnotationsArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistAnnotationT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l('This report lists artists with annotations.')}
    entityType="artist"
    extraInfo={ANNOTATION_REPORT_TEXT()}
    filtered={filtered}
    generated={generated}
    title={l('Artist annotations')}
    totalEntries={pager.total_entries}
  >
    <ArtistAnnotationList items={items} pager={pager} />
  </ReportLayout>
);

export default AnnotationsArtists;
