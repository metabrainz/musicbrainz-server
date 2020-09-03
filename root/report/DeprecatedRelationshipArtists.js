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

import ArtistRelationshipList from './components/ArtistRelationshipList';
import FilterLink from './FilterLink';
import type {ReportArtistRelationshipT, ReportDataT} from './types';

const DeprecatedRelationshipArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistRelationshipT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Artists with deprecated relationships')}>
    <h1>{l('Artists with deprecated relationships')}</h1>

    <ul>
      <li>
        {l(`This report lists artists which have relationships using
            deprecated and grouping-only relationship types.`)}
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

    <ArtistRelationshipList items={items} pager={pager} />

  </Layout>
);

export default DeprecatedRelationshipArtists;
