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
import {l_attributes} from '../../static/scripts/common/i18n/attributes';
import PaginatedResults from '../../components/PaginatedResults';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import primaryAreaCode from '../../static/scripts/common/utility/primaryAreaCode';
import loopParity from '../../utility/loopParity';

import ResultsLayout from './ResultsLayout';

type Props = {|
  +$c: CatalystContextT,
  +form: SearchFormT,
  +lastUpdated?: string,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<AreaT>>,
|};

function buildResult(result, index) {
  const area = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} key={area.id}>
      <td>{score}</td>
      <td>
        <DescriptiveLink entity={area} />
      </td>
      <td>
        {area.typeName ? l_attributes(area.typeName) : null}
      </td>
      <td>{primaryAreaCode(area)}</td>
      <td>{formatDate(area.begin_date)}</td>
      <td>
        {area.end_date
          ? formatDate(area.end_date)
          : area.ended ? l('[unknown]') : null}
      </td>
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
}: Props) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    {results.length ? (
      <PaginatedResults pager={pager} query={query} search>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('Score')}</th>
              <th>{l('Name')}</th>
              <th>{l('Type')}</th>
              <th>{l('Code')}</th>
              <th>{l('Begin')}</th>
              <th>{l('End')}</th>
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
