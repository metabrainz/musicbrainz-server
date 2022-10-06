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
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import formatEndDate
  from '../../static/scripts/common/utility/formatEndDate.js';
import primaryAreaCode
  from '../../static/scripts/common/utility/primaryAreaCode.js';
import {isLocationEditor}
  from '../../static/scripts/common/utility/privileges.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<AreaT>, index: number) {
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
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<AreaT>): React.Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
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
};

export default AreaResults;
