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

import LabelList from './components/LabelList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportLabelT} from './types';

const DuplicateRelationshipsLabels = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Labels with possible duplicate relationships')}
  >
    <h1>{l('Labels with possible duplicate relationships')}</h1>

    <ul>
      <li>
        {l(`This report lists labels which have multiple relationships
            to the same entity using the same relationship type.`)}
      </li>
      <li>
        {texp.l('Total labels found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <LabelList items={items} pager={pager} />

  </Layout>
);

export default DuplicateRelationshipsLabels;
