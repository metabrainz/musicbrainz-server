/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from '../../components/list/ArtistList';
import type {
  InlineResultsReactTablePropsT,
  ResultsReactTablePropsWithContextT,
} from '../types';

import {PaginatedSearchResultsReactTable} from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

export const ArtistResultsInline = ({
  $c,
  entities,
  pager,
  query,
  resultsNumber,
  scores,
}: InlineResultsReactTablePropsT<ArtistT>):
React.Element<typeof PaginatedSearchResultsReactTable> => (
  <PaginatedSearchResultsReactTable
    pager={pager}
    query={query}
    resultsNumber={resultsNumber}
    table={
      <ArtistList
        $c={$c}
        artists={entities}
        scores={scores}
        showBeginEnd
        showSortName
      />
    }
  />
);

const ArtistResults = ({
  $c,
  entities,
  form,
  lastUpdated,
  pager,
  query,
  resultsNumber,
  scores,
}: ResultsReactTablePropsWithContextT<ArtistT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
    <ArtistResultsInline
      $c={$c}
      entities={entities}
      pager={pager}
      query={query}
      resultsNumber={resultsNumber}
      scores={scores}
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

export default ArtistResults;
