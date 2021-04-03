/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditorLink from '../../static/scripts/common/components/EditorLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const editor = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={editor.id}>
      <td>
        <EditorLink editor={editor} />
      </td>
    </tr>
  );
}

const EditorResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<EditorT>):
React.Element<typeof ResultsLayout> => (
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

export default EditorResults;
