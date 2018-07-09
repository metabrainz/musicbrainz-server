/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import {l} from '../../static/scripts/common/i18n';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const series = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} key={series.id}>
      <td>{result.score}</td>
      <td>
        <EntityLink entity={series} />
      </td>
      <td>
        {series.typeName ? lp_attributes(series.typeName, 'series_type') : null}
      </td>
    </tr>
  );
}

const SeriesResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<SeriesT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    {results.length ? (
      <PaginatedResults pager={pager} query={query} search>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('Score')}</th>
              <th>{l('Name')}</th>
              <th>{l('Type')}</th>
            </tr>
          </thead>
          <tbody>
            {results.map(buildResult)}
          </tbody>
        </table>
      </PaginatedResults>
    ) : (
      <p>{l('No results found. Try refining your search query.')}</p>
    )}
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {l('Alternatively, you may {uri|add a new series}.', {
          __react: true,
          uri: '/series/create?edit-series.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(SeriesResults);
