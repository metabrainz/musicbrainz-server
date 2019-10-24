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

import RecordingRelationshipList
  from './components/RecordingRelationshipList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingRelationshipT} from './types';

const DeprecatedRelationshipRecordings = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingRelationshipT>) => (
  <Layout fullWidth title={l('Recordings with deprecated relationships')}>
    <h1>{l('Recordings with deprecated relationships')}</h1>

    <ul>
      <li>
        {l(`This report lists recordings which have relationships using
            deprecated and grouping-only relationship types.`)}
      </li>
      <li>
        {texp.l('Total recordings found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c.user, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <RecordingRelationshipList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DeprecatedRelationshipRecordings);
