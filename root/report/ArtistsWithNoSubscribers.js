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

import ArtistList from './components/ArtistList';
import FilterLink from './FilterLink';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsWithNoSubscribers = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Artists with no subscribers')}>
    <h1>{l('Artists with no subscribers')}</h1>

    <ul>
      <li>
        {l(`This report lists artists that have no editors subscribed to them,
            and whose changes may therefore be under-reviewed. Artists with
            more release groups and more open edits are listed first.`)}
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

    <ArtistList items={items} pager={pager} />

  </Layout>
);

export default ArtistsWithNoSubscribers;
