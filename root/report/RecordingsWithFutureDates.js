/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import RecordingRelationshipList
  from './components/RecordingRelationshipList';
import type {ReportDataT, ReportRecordingRelationshipT} from './types';

type Props = ReportDataT<ReportRecordingRelationshipT>;

const RecordingsWithFutureDates = ({
  $c,
  generated,
  items,
  pager,
}: Props): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Recordings with relationships having dates in the future')}
  >
    <h1>{l('Recordings with relationships having dates in the future')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows recordings with relationships using dates in
           the future. Those are probably typos
           (e.g. 2109 instead of 2019).`,
        )}
      </li>
      <li>
        {texp.l('Total relationships found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>
    </ul>

    <RecordingRelationshipList items={items} pager={pager} showDates />

  </Layout>
);

export default RecordingsWithFutureDates;
