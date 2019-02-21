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

import ArtistList from './components/ArtistList';
import FilterLink from './FilterLink';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsThatMayBeGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>) => (
  <Layout fullWidth title={l('Artists that may be groups')}>
    <h1>{l('Artists that may be groups')}</h1>

    <ul>
      <li>
        {l(`This report lists artists that have their type set to other
            than Group (or a subtype of Group) but may be a group,
            because they have other artists listed as members. If you find
            that an artist here is indeed a group, change its type. If it is
            not, please make sure that the "member of" relationships are
            in the right direction and are correct.`)}
      </li>
      <li>
        {texp.l('Total artists found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c.user, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ArtistList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(ArtistsThatMayBeGroups);
