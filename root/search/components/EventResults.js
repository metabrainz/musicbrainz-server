/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import uniq from 'lodash/uniq';

import {withCatalystContext} from '../../context';
import {l} from '../../static/scripts/common/i18n';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDatePeriod from '../../static/scripts/common/utility/formatDatePeriod';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const event = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} key={event.id}>
      <td>{score}</td>
      <td>
        <DescriptiveLink entity={event} />
      </td>
      <td>{event.typeName ? lp_attributes(event.typeName, 'event_type') : null}</td>
      <td>
        <ul>
          {event.performers.map(r =>(
            <li key={r.entity.id}>
              {l('{artist} ({roles})', {
                __react: true,
                artist: <EntityLink entity={r.entity} />,
                roles: r.roles.length > 1
                  // $FlowFixMe
                  ? commaOnlyList(uniq(r.roles))
                  : r.roles[0],
              })}
            </li>
          ))}
        </ul>
      </td>
      <td>
        <ul>
          {event.places.map(r => (
            <li key={r.entity.id}>
              <DescriptiveLink entity={r.entity} />
            </li>
          ))}
          {event.areas.map(r => (
            <li key={r.entity.id}>
              <DescriptiveLink entity={r.entity} />
            </li>
          ))}
        </ul>
      </td>
      <td>{formatDatePeriod(event)}</td>
      <td>{event.time}</td>
    </tr>
  );
}

const EventResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<EventT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={[
        l('Score'),
        l('Name'),
        l('Type'),
        l('Artists'),
        l('Location'),
        l('Date'),
        l('Time'),
      ]}
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {l('Alternatively, you may {uri|add a new event}.', {
          __react: true,
          uri: '/event/create?edit-event.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(EventResults);
