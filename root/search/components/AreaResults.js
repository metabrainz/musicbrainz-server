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
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import primaryAreaCode from '../../static/scripts/common/utility/primaryAreaCode';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

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
        {area.typeName ? lp_attributes(area.typeName, 'area_type') : null}
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
}: ResultsPropsT<AreaT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={[
        l('Name'),
        l('Type'),
        l('Code'),
        l('Begin'),
        l('End'),
      ]}
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && $c.user.is_location_editor ? (
      <p>
        {l('Alternatively, you may {uri|add a new area}.', {
          __react: true,
          uri: '/area/create?edit-area.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(AreaResults);
