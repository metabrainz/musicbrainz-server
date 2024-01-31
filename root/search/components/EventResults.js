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
import * as manifest from '../../static/manifest.mjs';
import ArtistRoles
  from '../../static/scripts/common/components/ArtistRoles.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import EventLocations
  from '../../static/scripts/common/components/EventLocations.js';
import formatDatePeriod
  from '../../static/scripts/common/utility/formatDatePeriod.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<EventT>, index: number) {
  const event = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={event.id}>
      <td>
        <EntityLink entity={event} showDisambiguation showEventDate={false} />
      </td>
      <td>{formatDatePeriod(event)}</td>
      <td>{event.time}</td>
      <td>
        {nonEmpty(event.typeName)
          ? lp_attributes(event.typeName, 'event_type')
          : null}
      </td>
      <td>
        <ArtistRoles relations={event.performers} />
        {manifest.js(
          'common/components/ArtistRoles',
          {async: 'async'},
        )}
      </td>
      <td>
        <EventLocations event={event} />
      </td>
    </tr>
  );
}

const EventResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<EventT>): React$Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={buildResult}
        columns={
          <>
            <th>{l('Name')}</th>
            <th>{l('Date')}</th>
            <th>{lp('Time', 'event')}</th>
            <th>{l('Type')}</th>
            <th>{l('Artists')}</th>
            <th>{lp('Location', 'event location')}</th>
          </>
        }
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new event}.', {
            uri: '/event/create?edit-event.name=' + encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
};

export default EventResults;
