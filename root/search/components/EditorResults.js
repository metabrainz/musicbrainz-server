/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<EditorT>, index: number) {
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

component EditorResults(...{
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<EditorT>) {
  return (
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
}

export default EditorResults;
