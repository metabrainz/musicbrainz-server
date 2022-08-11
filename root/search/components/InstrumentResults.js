/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../context.mjs';
import InstrumentListEntry
  from '../../static/scripts/common/components/InstrumentListEntry.js';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(
  result: SearchResultT<InstrumentT>,
  index: number,
) {
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
}: ResultsPropsT<InstrumentT>):
React.Element<typeof ResultsLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={(result, index) => buildResult(result, index)}
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
      {isRelationshipEditor($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new instrument}.', {
            uri: '/instrument/create?edit-instrument.name=' +
              encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
};

export default InstrumentResults;
