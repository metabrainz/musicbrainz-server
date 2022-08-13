/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import formatEndDate
  from '../../static/scripts/common/utility/formatEndDate.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import formatLabelCode from '../../utility/formatLabelCode.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<LabelT>, index: number) {
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
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<LabelT>): React.Element<typeof ResultsLayout> => {
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
};

export default LabelResults;
