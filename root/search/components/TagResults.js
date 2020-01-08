/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import TagLink from '../../static/scripts/common/components/TagLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const tag = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={tag.name}>
      <td>
        <TagLink tag={tag.name} />
      </td>
      <td>
        {tag.genre ? (
          <EntityLink entity={tag.genre} />
        ) : null}
      </td>
    </tr>
  );
}

const TagResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<TagT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Genre')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  </ResultsLayout>
);

export default TagResults;
