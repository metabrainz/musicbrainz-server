/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import WorkRelationshipList from './components/WorkRelationshipList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportWorkRelationshipT} from './types';

const DeprecatedRelationshipWorks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkRelationshipT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Works with deprecated relationships')}>
    <h1>{l('Works with deprecated relationships')}</h1>

    <ul>
      <li>
        {l(`This report lists works which have relationships using
            deprecated and grouping-only relationship types.`)}
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

    <WorkRelationshipList items={items} pager={pager} />

  </Layout>
);

export default DeprecatedRelationshipWorks;
