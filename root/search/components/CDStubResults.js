/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDStubLink from '../../static/scripts/common/components/CDStubLink.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<CDStubT>, index: number) {
  const cdstub = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={cdstub.discid}>
      <td>
        <CDStubLink cdstub={cdstub} content={cdstub.title} />
      </td>
      <td>{cdstub.artist}</td>
      <td>{cdstub.track_count}</td>
    </tr>
  );
}

const CDStubResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<CDStubT>): React.Element<typeof ResultsLayout> => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('CD Stub')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Tracks')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  </ResultsLayout>
);

export default CDStubResults;
