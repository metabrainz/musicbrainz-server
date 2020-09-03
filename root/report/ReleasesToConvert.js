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

const ReleasesToConvert = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Releases which might need converting to "multiple artists"')}
  >
    <h1>{l('Releases which might need converting to "multiple artists"')}</h1>

    <ul>
      <li>
        {l(`This report aims to identify releases which need converting to
            multiple artists (because the track artists are on the title
            field, for example). Currently it does this by looking for
            releases where every track contains "/" or "-".`)}
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

export default ReleasesToConvert;
