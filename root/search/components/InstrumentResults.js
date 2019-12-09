/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../context';
import InstrumentListEntry
  from '../../static/scripts/common/components/InstrumentListEntry';
import type {ResultsPropsWithContextT} from '../types';

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
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<InstrumentT>) => (
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
    {$c.user && $c.user.is_relationship_editor ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new instrument}.', {
          uri: '/instrument/create?edit-instrument.name=' +
            encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(InstrumentResults);
