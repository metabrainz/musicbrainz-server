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

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const ReleasesConflictingDiscIds = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Releases with conflicting disc IDs')}>
    <h1>{l('Releases with conflicting disc IDs')}</h1>

    <ul>
      <li>
        {l(`This report shows releases that have conflicting disc IDs on the
            same medium with significant differences in duration. This usually
            means a disc ID was applied to the wrong medium or the wrong
            release.`)}
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

    <ReleaseList items={items} pager={pager} subPath="discids" />

  </Layout>
);

export default ReleasesConflictingDiscIds;
