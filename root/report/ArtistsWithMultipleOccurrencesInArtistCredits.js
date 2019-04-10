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
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsWithMultipleOccurrencesInArtistCredits = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>) => (
  <Layout
    fullWidth
    title={l('Artists occurring multiple times in the same artist credit')}
  >
    <h1>{l('Artists occurring multiple times in the same artist credit')}</h1>

    <ul>
      <li>
        {l(`This report lists artists that appear more than once in different
            positions within the same artist credit.`)}
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

    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Artist')}</th>
            <th>{l('Type')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.artist.gid}>
              <td>
                <EntityLink entity={item.artist} subPath="aliases" />
              </td>
              <td>
                {item.artist.typeName
                  ? lp_attributes(item.artist.typeName, 'artist_type')
                  : l('Unknown')}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(
  ArtistsWithMultipleOccurrencesInArtistCredits,
);
