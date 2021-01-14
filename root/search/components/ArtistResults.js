/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistListEntry
  from '../../static/scripts/common/components/ArtistListEntry';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges';
import type {
  InlineResultsPropsWithContextT,
  ResultsPropsWithContextT,
} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult($c, result, index) {
  const artist = result.entity;
  const score = result.score;

  return (
    <ArtistListEntry
      $c={$c}
      artist={artist}
      index={index}
      key={artist.id}
      score={score}
      showBeginEnd
      showSortName
    />
  );
}

export const ArtistResultsInline = ({
  $c,
  pager,
  query,
  results,
}: InlineResultsPropsWithContextT<ArtistT>):
React.Element<typeof PaginatedSearchResults> => (
  <PaginatedSearchResults
    buildResult={(result, index) => buildResult($c, result, index)}
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
}: ResultsPropsWithContextT<ArtistT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
    <ArtistResultsInline
      $c={$c}
      pager={pager}
      query={query}
      results={results}
    />
    {isEditingEnabled($c.user) ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new artist}.', {
          uri: '/artist/create?edit-artist.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default ArtistResults;
