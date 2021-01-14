/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges';
import formatLabelCode from '../../utility/formatLabelCode';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const label = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={label.id}>
      <td>
        <EntityLink entity={label} />
      </td>
      <td>
        {nonEmpty(label.typeName)
          ? lp_attributes(label.typeName, 'label_type')
          : null}
      </td>
      <td>
        {label.label_code ? formatLabelCode(label.label_code) : null}
      </td>
      <td>
        {label.area ? <EntityLink entity={label.area} /> : null}
      </td>
      <td>{formatDate(label.begin_date)}</td>
      <td>{formatEndDate(label)}</td>
    </tr>
  );
}

const LabelResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<LabelT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Code')}</th>
          <th>{l('Area')}</th>
          <th>{l('Begin')}</th>
          <th>{l('End')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
    {isEditingEnabled($c.user) ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new label}.', {
          uri: '/label/create?edit-label.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default LabelResults;
