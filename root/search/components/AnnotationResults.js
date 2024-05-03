/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<AnnotationT>, index: number) {
  const annotation = result.entity;
  const score = result.score;

  return (
    <tr
      className={loopParity(index)}
      data-score={score}
      key={annotation.parent ? annotation.parent.gid : index}
    >
      <td>
        {annotation.parent
          ? formatEntityTypeName(annotation.parent.entityType)
          : null}
      </td>
      <td>
        {annotation.parent ? <EntityLink entity={annotation.parent} /> : null}
      </td>
      <td dangerouslySetInnerHTML={{__html: annotation.html}} />
    </tr>
  );
}

component AnnotationResults(...{
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<AnnotationT>) {
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={buildResult}
        columns={
          <>
            <th>{l('Type')}</th>
            <th>{l('Name')}</th>
            <th>{l('Annotation')}</th>
          </>
        }
        pager={pager}
        query={query}
        results={results}
      />
    </ResultsLayout>
  );
}

export default AnnotationResults;
