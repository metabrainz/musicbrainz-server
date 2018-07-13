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
import {l} from '../../static/scripts/common/i18n';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import primaryAreaCode from '../../static/scripts/common/utility/primaryAreaCode';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const artist = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} key={artist.id}>
      <td>{result.score}</td>
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

const ArtistResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<ArtistT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={[
        l('Score'),
        l('Name'),
        l('Sort Name'),
        l('Type'),
        l('Gender'),
        l('Area'),
        l('Begin'),
        l('Begin Area'),
        l('End'),
        l('End Area'),
      ]}
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {l('Alternatively, you may {uri|add a new artist}.', {
          __react: true,
          uri: '/artist/create?edit-artist.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(ArtistResults);
