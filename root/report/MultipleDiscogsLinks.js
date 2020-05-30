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

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const MultipleDiscogsLinks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Releases with multiple Discogs links')}>
    <h1>{l('Releases with multiple Discogs links')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows releases that have more than one link to Discogs.
           In most cases a MusicBrainz release should have only one equivalent
           in Discogs, so only one of them will be correct. Just check which
           ones do not fit the release (because of format, different number of
           tracks, etc). Any "master" Discogs page belongs at the
           {release_group|release group level}, not at the release level, and
           should be removed from releases too.`,
          {release_group: '/doc/Release_Group'},
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

export default MultipleDiscogsLinks;
