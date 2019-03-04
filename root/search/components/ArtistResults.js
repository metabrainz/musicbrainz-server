/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import loopParity from '../../utility/loopParity';
import type {InlineResultsPropsT, ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const artist = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={artist.id}>
      <td>
        <EntityLink entity={artist} />
      </td>
      <td>{artist.sort_name}</td>
      <td>
        {artist.typeName ? lp_attributes(artist.typeName, 'artist_type') : null}
      </td>
      <td>
        {artist.gender ? lp_attributes(artist.gender.name, 'gender') : null}
      </td>
      <td>
        {artist.area ? <EntityLink entity={artist.area} /> : null}
      </td>
      <td>{formatDate(artist.begin_date)}</td>
      <td>
        {artist.begin_area ? <EntityLink entity={artist.begin_area} /> : null}
      </td>
      <td>{formatEndDate(artist)}</td>
      <td>
        {artist.end_area ? <EntityLink entity={artist.end_area} /> : null}
      </td>
    </tr>
  );
}

export const ArtistResultsInline = ({
  pager,
  query,
  results,
}: InlineResultsPropsT<ArtistT>) => (
  <PaginatedSearchResults
    buildResult={buildResult}
    columns={
      <>
        <th>{l('Name')}</th>
        <th>{l('Sort Name')}</th>
        <th>{l('Type')}</th>
        <th>{l('Gender')}</th>
        <th>{l('Area')}</th>
        <th>{l('Begin')}</th>
        <th>{l('Begin Area')}</th>
        <th>{l('End')}</th>
        <th>{l('End Area')}</th>
      </>
    }
    pager={pager}
    query={query}
    results={results}
  />
);

const ArtistResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<ArtistT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <ArtistResultsInline
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new artist}.', {
          uri: '/artist/create?edit-artist.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(ArtistResults);
