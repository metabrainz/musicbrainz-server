/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import primaryAreaCode
  from '../../static/scripts/common/utility/primaryAreaCode';
import {isLocationEditor}
  from '../../static/scripts/common/utility/privileges';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const area = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={area.id}>
      <td>
        <DescriptiveLink entity={area} />
      </td>
      <td>
        {nonEmpty(area.typeName)
          ? lp_attributes(area.typeName, 'area_type')
          : null}
      </td>
      <td>{primaryAreaCode(area)}</td>
      <td>{formatDate(area.begin_date)}</td>
      <td>{formatEndDate(area)}</td>
    </tr>
  );
}

const AreaResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<AreaT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Code')}</th>
          <th>{l('Begin')}</th>
          <th>{l('End')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
    {isLocationEditor($c.user) ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new area}.', {
          uri: '/area/create?edit-area.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default AreaResults;
