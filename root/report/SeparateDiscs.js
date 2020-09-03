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

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const SeparateDiscs = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Discs as separate releases')}>
    <h1>{l('Discs as separate releases')}</h1>

    <ul>
      <li>
        {l(
          `This report shows releases which have (disc n) or (bonus disc)
           in the title.`,
        )}
      </li>
      <li>
        {exp.l(
          `For instructions on how to fix them, please see the documentation
           about {howto|how to merge releases}.`,
          {howto: '/doc/How_to_Merge_Releases'},
        )}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default SeparateDiscs;
