/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import ArtistListEntry
  from '../../static/scripts/common/components/ArtistListEntry.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import type {
  InlineResultsPropsT,
  ResultsPropsT,
  SearchResultT,
} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<ArtistT>, index: number) {
  const artist = result.entity;
  const score = result.score;

  return (
    <ArtistListEntry
      artist={artist}
      index={index}
      key={artist.id}
      score={score}
      showBeginEnd
      showSortName
    />
  );
}

export component ArtistResultsInline(...{
  pager,
  query,
  results,
}: InlineResultsPropsT<ArtistT>) {
  return (
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Sort name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Gender')}</th>
          <th>{l('Area')}</th>
          <th>{l('Begin')}</th>
          <th>{l('Begin area')}</th>
          <th>{l('End')}</th>
          <th>{l('End area')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  );
}

component ArtistResults(...{
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<ArtistT>) {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <ArtistResultsInline
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new artist}.', {
            uri: '/artist/create?edit-artist.name=' +
              encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
}

export default ArtistResults;
