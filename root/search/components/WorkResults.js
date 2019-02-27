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
import {l} from '../../static/scripts/common/i18n';
import WorkListEntry from '../../static/scripts/common/components/WorkListEntry';
import type {ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const work = result.entity;
  const score = result.score;

  return (
    <WorkListEntry
      hasIswcColumn
      hasMergeColumn={false}
      index={index}
      key={work.id}
      score={score}
      work={work}
    />
  );
}

const WorkResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<WorkT>) => (
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
          <th>{l('Lyrics Languages')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {l('Alternatively, you may {uri|add a new work}.', {
          uri: '/work/create?edit-work.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(WorkResults);
