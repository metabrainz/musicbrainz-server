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
import ArtistRoles from '../../static/scripts/common/components/ArtistRoles';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatDatePeriod from '../../static/scripts/common/utility/formatDatePeriod';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const event = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={event.id}>
      <td>
        <DescriptiveLink entity={event} />
      </td>
      <td>{event.typeName ? lp_attributes(event.typeName, 'event_type') : null}</td>
      <td>
        <ArtistRoles relations={event.performers} />
      </td>
      <td>
        <ul>
          {event.places.map(place => (
            <li key={place.entity.id}>
              <DescriptiveLink entity={place.entity} />
            </li>
          ))}
          {event.areas.map(area => (
            <li key={area.entity.id}>
              <DescriptiveLink entity={area.entity} />
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
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Artists')}</th>
          <th>{l('Location')}</th>
          <th>{l('Date')}</th>
          <th>{l('Time')}</th>
        </>
      }
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
