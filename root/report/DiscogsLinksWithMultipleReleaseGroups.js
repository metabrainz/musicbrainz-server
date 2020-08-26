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

import ReleaseGroupUrlList from './components/ReleaseGroupUrlList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseGroupUrlT} from './types';

const DiscogsLinksWithMultipleReleaseGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupUrlT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Discogs URLs linked to multiple release groups')}
  >
    <h1>{l('Discogs URLs linked to multiple release groups')}</h1>

    <ul>
      <li>
        {l(`This report shows Discogs URLs which are linked
            to multiple release groups.`)}
      </li>
      <li>
        {texp.l('Total release groups found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupUrlList items={items} pager={pager} />

  </Layout>
);

export default DiscogsLinksWithMultipleReleaseGroups;
