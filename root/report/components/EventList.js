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
import EventLocations
  from '../../static/scripts/common/components/EventLocations';
import type {ReportEventT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportEventT>,
  +pager: PagerT,
};

const EventList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
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
        {items.map((item, index) => {
          const event = item.event;
          return (
            <tr className={loopParity(index)} key={item.event_id}>
              {event ? (
                <>
                  <td>
                    <EntityLink
                      entity={event}
                      showDisambiguation
                      showEventDate={false}
                    />
                  </td>
                  <td>
                    {event.typeName
                      ? lp_attributes(event.typeName, 'event_type')
                      : null}
                  </td>
                  <td>
                    <ArtistRoles relations={event.performers} />
                  </td>
                  <td>
                    <EventLocations event={event} />
                  </td>
                  <td>{formatDatePeriod(event)}</td>
                  <td>{event.time}</td>
                </>
              ) : (
                <td colSpan="6">
                  {l('This event no longer exists.')}
                </td>
              )}
            </tr>
          );
        })}
      </tbody>
    </table>
  </PaginatedResults>
);

export default EventList;
