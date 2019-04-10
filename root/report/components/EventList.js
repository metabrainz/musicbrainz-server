/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import formatDatePeriod
  from '../../static/scripts/common/utility/formatDatePeriod';
import ArtistRoles from '../../static/scripts/common/components/ArtistRoles';
import EventLocations from '../../static/scripts/common/components/EventLocations';
import type {ReportEventT} from '../types';

const EventList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportEventT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Event')}</th>
          <th>{l('Type')}</th>
          <th>{l('Artists')}</th>
          <th>{l('Location')}</th>
          <th>{l('Date')}</th>
          <th>{l('Time')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.event.id}>
            <td>
              <EntityLink
                entity={item.event}
                showDisambiguation
                showEventDate={false}
              />
            </td>
            <td>
              {item.event.typeName
                ? lp_attributes(item.event.typeName, 'event_type')
                : null}
            </td>
            <td>
              <ArtistRoles relations={item.event.performers} />
            </td>
            <td>
              <EventLocations event={item.event} />
            </td>
            <td>{formatDatePeriod(item.event)}</td>
            <td>{item.event.time}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default EventList;
