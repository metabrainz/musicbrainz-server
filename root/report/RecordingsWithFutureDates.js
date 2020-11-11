/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingRelationshipList
  from './components/RecordingRelationshipList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingRelationshipT} from './types';


const RecordingsWithFutureDates = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings with relationships using dates in
       the future. Those are probably typos (e.g. 2109 instead of 2019).`,
    )}
    entityType="relationship"
    filtered={filtered}
    generated={generated}
    title={l('Recordings with relationships having dates in the future')}
    totalEntries={pager.total_entries}
  >
    <RecordingRelationshipList items={items} pager={pager} showDates />
  </ReportLayout>
);

export default RecordingsWithFutureDates;
