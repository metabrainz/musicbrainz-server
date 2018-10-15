/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import TagLink from '../../static/scripts/common/components/TagLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const tag = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={tag}>
      <td>
        <TagLink tag={tag} />
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
}: ResultsPropsT<string>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  </ResultsLayout>
);

export default TagResults;
