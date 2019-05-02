/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList';
import localizeArtistRoles
  from '../static/scripts/common/i18n/localizeArtistRoles';
import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';
import ArtistRoles from '../static/scripts/common/components/ArtistRoles';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EventLocations
  from '../static/scripts/common/components/EventLocations';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod';

import RatingStars from './RatingStars';
import SortableTableHeader from './SortableTableHeader';

type Props = {|
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +artist?: ArtistT,
  +artistRoles?: boolean,
  +checkboxes?: string,
  +events: $ReadOnlyArray<EventT>,
  +noArtists?: boolean,
  +noLocation?: boolean,
  +noRatings?: boolean,
  +noType?: boolean,
  +order?: string,
  +sortable?: boolean,
|};

const EventsList = ({
  $c,
  artist,
  artistRoles,
  checkboxes,
  events,
  noArtists,
  noLocation,
  noRatings,
  noType,
  order,
  seriesItemNumbers,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th style={{width: '1em'}}>
            <input type="checkbox" />
          </th>
        ) : null}
        {seriesItemNumbers ? <th style={{width: '1em'}}>{l('#')}</th> : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Event')}
                name="name"
                order={order}
              />
            )
            : l('Event')}
        </th>
        {noType ? null : (
          <th>
            {sortable
              ? (
                <SortableTableHeader
                  label={l('Type')}
                  name="type"
                  order={order}
                />
              )
              : l('Type')}
          </th>
        )}
        {noArtists ? null : <th>{l('Artists')}</th>}
        {artistRoles ? <th>{l('Role')}</th> : null}
        {noLocation ? null : <th>{l('Location')}</th>}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Date')}
                name="date"
                order={order}
              />
            )
            : l('Date')}
        </th>
        <th>{l('Time')}</th>
        {noRatings ? null : <th>{l('Rating')}</th>}
      </tr>
    </thead>
    <tbody>
      {events.map((event, index) => (
        <tr className={loopParity(index)} key={event.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={event.id}
              />
            </td>
          ) : null}
          {seriesItemNumbers ? (
            <td style={{width: '1em'}}>
              {seriesItemNumbers[event.id]}
            </td>
          ) : null}
          <td>
            <DescriptiveLink entity={event} />
          </td>
          {noType ? null : (
            <td>
              {event.typeName
                ? lp_attributes(event.typeName, 'event_type')
                : null}
            </td>
          )}
          {noArtists ? null : (
            <td>
              <ArtistRoles relations={event.performers} />
            </td>
          )}
          {artist && artistRoles ? (
            <td>
              {event.performers.map(performer => (
                performer.entity.id === artist.id ? (
                  commaOnlyList(localizeArtistRoles(performer.roles))
                ) : null
              ))}
            </td>
          ) : null}
          {noLocation ? null : (
            <td>
              <EventLocations event={event} />
            </td>
          )}
          <td>{formatDatePeriod(event)}</td>
          <td>{event.time}</td>
          {noRatings ? null : (
            <td>
              <RatingStars entity={event} />
            </td>
          )}
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(EventsList);
