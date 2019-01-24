/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import formatDatePeriod
  from '../../static/scripts/common/utility/formatDatePeriod';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import ArtistRoles from '../../static/scripts/common/components/ArtistRoles';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
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
            <td>{item.event.typeName ? lp_attributes(item.event.typeName, 'event_type') : null}</td>
            <td>
              <ArtistRoles relations={item.event.performers} />
            </td>
            <td>
              <ul>
                {item.event.places.map(place => (
                  <li key={place.entity.id}>
                    <DescriptiveLink entity={place.entity} />
                  </li>
                ))}
                {item.event.areas.map(area => (
                  <li key={area.entity.id}>
                    <DescriptiveLink entity={area.entity} />
                  </li>
                ))}
              </ul>
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
