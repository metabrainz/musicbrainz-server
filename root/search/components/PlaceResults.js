/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsWithContextT, SearchResultT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result: SearchResultT<PlaceT>, index: number) {
  const place = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={place.id}>
      <td>
        <EntityLink entity={place} />
      </td>
      <td>
        {nonEmpty(place.typeName)
          ? lp_attributes(place.typeName, 'place_type')
          : null}
      </td>
      <td>{place.address}</td>
      <td>
        {place.area ? <EntityLink entity={place.area} /> : null}
      </td>
      <td>{formatDate(place.begin_date)}</td>
      <td>{formatEndDate(place)}</td>
    </tr>
  );
}

const PlaceResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<PlaceT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Address')}</th>
          <th>{l('Area')}</th>
          <th>{l('Begin')}</th>
          <th>{l('End')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
    {isEditingEnabled($c.user) ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new place}.', {
          uri: '/place/create?edit-place.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default PlaceResults;
