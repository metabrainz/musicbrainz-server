/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import RecordingList from './components/RecordingList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingT} from './types';

const RecordingsWithEarliestReleaseRelationships = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) => (
  <Layout fullWidth title={l('Recordings with earliest release relationships')}>
    <h1>{l('Recordings with earliest release relationships')}</h1>

    <ul>
      <li>
        {l(`This report shows recordings that have the deprecated "earliest
            release" relationship. They should be merged if they are truly
            the same recording; if they're not, the relationship should be
            removed. Please, do not merge recordings blindly just because
            the lengths fit, and do not merge recordings with very different
            times!`)}
      </li>
      <li>{texp.l('Total recordings found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <RecordingList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(
  RecordingsWithEarliestReleaseRelationships,
);
