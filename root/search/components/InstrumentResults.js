/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import InstrumentListEntry
  from '../../static/scripts/common/components/InstrumentListEntry';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const instrument = result.entity;
  const score = result.score;

  return (
    <InstrumentListEntry
      index={index}
      instrument={instrument}
      key={instrument.id}
      score={score}
    />
  );
}

const InstrumentResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<InstrumentT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Description')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  </ResultsLayout>
);

export default InstrumentResults;
