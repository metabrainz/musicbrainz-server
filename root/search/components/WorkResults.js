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
import WorkListEntry
  from '../../static/scripts/common/components/WorkListEntry.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(
  result: SearchResultT<WorkT>,
  index: number,
) {
  const work = result.entity;
  const score = result.score;

  return (
    <WorkListEntry
      index={index}
      key={work.id}
      score={score}
      showIswcs
      work={work}
    />
  );
}

component WorkResults(...{
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<WorkT>) {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={buildResult}
        columns={
          <>
            <th>{l('Name')}</th>
            <th>{l('Writers')}</th>
            <th>{l('Artists')}</th>
            <th>{l('ISWC')}</th>
            <th>{l('Type')}</th>
            <th>{l('Lyrics languages')}</th>
          </>
        }
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new work}.', {
            uri: '/work/create?edit-work.name=' + encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
}

export default WorkResults;
