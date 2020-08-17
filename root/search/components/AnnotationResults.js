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
import expand2react from '../../static/scripts/common/i18n/expand2react';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
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
      <td>{expand2react(annotation.html)}</td>
    </tr>
  );
}

const AnnotationResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<AnnotationT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
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

export default AnnotationResults;
