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

import ReleaseGroupList from './components/ReleaseGroupList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseGroupT} from './types';

const ReleaseGroupsWithoutVaLink = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) => (
  <Layout
    fullWidth
    title={l(`Release groups credited to "Various Artists"
              but not linked to VA`)}
  >
    <h1>
      {l('Release groups credited to "Various Artists" but not linked to VA')}
    </h1>

    <ul>
      <li>
        {l(`This report shows release groups with "Various Artists" as the
            credited name but not linked to the Various Artists entity.`)}
      </li>
      <li>
        {texp.l('Total release groups found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(ReleaseGroupsWithoutVaLink);
