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

import ArtistUrlList from './components/ArtistUrlList';
import FilterLink from './FilterLink';
import type {ReportArtistUrlT, ReportDataT} from './types';

const DiscogsLinksWithMultipleArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistUrlT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Discogs URLs linked to multiple artists')}>
    <h1>{l('Discogs URLs linked to multiple artists')}</h1>

    <ul>
      <li>
        {l(`This report shows Discogs URLs which are linked
            to multiple artists.`)}
      </li>
      <li>
        {texp.l('Total artists found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <ArtistUrlList items={items} pager={pager} />

  </Layout>
);

export default DiscogsLinksWithMultipleArtists;
