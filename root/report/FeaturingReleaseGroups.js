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

const FeaturingReleaseGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) => (
  <Layout
    fullWidth
    title={l('Release groups with titles containing featuring artists')}
  >
    <h1>{l('Release groups with titles containing featuring artists')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows release groups with “(feat. Artist)” 
           (or similar) in the title. For classical release groups, 
           consult the {CSG|classical style guidelines}. For 
           non-classical release groups, this is usually inherited from an
           older version of MusicBrainz and should be fixed. Consult the
           {featured_artists|page about featured artists} to know more.`,
          {
            CSG: '/doc/Style/Classical',
            featured_artists: '/doc/Style/Artist_Credits#Featured_artists',
          },
        )}
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

export default withCatalystContext(FeaturingReleaseGroups);
