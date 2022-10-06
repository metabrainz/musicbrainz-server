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
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(
  result: SearchResultT<SeriesT>,
  index: number,
) {
  const series = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={series.id}>
      <td>
        <EntityLink entity={series} />
      </td>
      <td>
        {nonEmpty(series.typeName)
          ? lp_attributes(series.typeName, 'series_type')
          : null}
      </td>
    </tr>
  );
}

const SeriesResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<SeriesT>): React.Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={buildResult}
        columns={
          <>
            <th>{l('Name')}</th>
            <th>{l('Type')}</th>
          </>
        }
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new series}.', {
            uri: '/series/create?edit-series.name=' +
              encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
};

export default SeriesResults;
