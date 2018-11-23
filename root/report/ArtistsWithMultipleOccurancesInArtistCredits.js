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
import {l} from '../static/scripts/common/i18n';
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsWithMultipleOccurancesInArtistCredits = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>) => (
  <Layout fullWidth title={l('Artists occuring multiple times in the same artist credit')}>
    <h1>{l('Artists occuring multiple times in the same artist credit')}</h1>

    <ul>
      <li>{l('This report lists artists that appear more than once in different \
            positions within the same artist credit.')}
      </li>
      <li>{l('Total artists found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

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
              <td>{item.artist.typeName ? item.artist.typeName : l('Unknown')}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(ArtistsWithMultipleOccurancesInArtistCredits);
