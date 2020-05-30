/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import WorkList from './components/WorkList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportWorkT} from './types';

const DuplicateRelationshipsWorks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Works with possible duplicate relationships')}>
    <h1>{l('Works with possible duplicate relationships')}</h1>

    <ul>
      <li>
        {l(`This report lists works which have multiple relationships
            to the same entity using the same relationship type.
            This excludes recording-work relationships. See the recording
            version of this report for those.`)}
      </li>
      <li>
        {texp.l('Total works found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <WorkList items={items} pager={pager} />

  </Layout>
);

export default DuplicateRelationshipsWorks;
