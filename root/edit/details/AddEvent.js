/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatDate from '../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import yesNo from '../../static/scripts/common/utility/yesNo';

type AddEventEditT = {
  ...EditT,
  +display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    +cancelled: boolean,
    +ended: boolean,
    +event: EventT,
    +name: string,
    +setlist: string,
    +time: string | null,
    +type: EventTypeT | null,
  },
};

type Props = {
  +edit: AddEventEditT,
};

const AddEvent = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const eventType = display.type;

  return (
    <>
      <table className="details">
        <tr>
          <th>{addColon(l('Event'))}</th>
          <td>
            <EntityLink
              entity={display.event}
            />
          </td>
        </tr>
      </table>

      <table className="details add-event">
        <tr>
          <th>{addColon(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>

        {display.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        <tr>
          <th>{addColon(l('Cancelled'))}</th>
          <td>{yesNo(display.cancelled)}</td>
        </tr>

        {eventType ? (
          <tr>
            <th>{addColon(l('Type'))}</th>
            <td>{lp_attributes(eventType.name, 'event_type')}</td>
          </tr>
        ) : null}

        {isDateEmpty(display.begin_date) ? null : (
          <tr>
            <th>{addColon(l('Begin date'))}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        )}

        {isDateEmpty(display.end_date) ? null : (
          <tr>
            <th>{addColon(l('End date'))}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        )}

        {nonEmpty(display.time) ? (
          <tr>
            <th>{addColon(l('Time'))}</th>
            <td>{display.time}</td>
          </tr>
        ) : null}

        {display.setlist ? (
          <tr>
            <th>{addColon(l('Setlist'))}</th>
            <td>{display.setlist}</td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default AddEvent;
