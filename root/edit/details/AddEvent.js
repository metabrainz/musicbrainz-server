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
          <th>{addColonText(l('Event'))}</th>
          <td>
            <EntityLink
              entity={display.event}
            />
          </td>
        </tr>
      </table>

      <table className="details add-event">
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>

        {display.comment ? (
          <tr>
            <th>{addColonText(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        <tr>
          <th>{addColonText(l('Cancelled'))}</th>
          <td>{yesNo(display.cancelled)}</td>
        </tr>

        {eventType ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(eventType.name, 'event_type')}</td>
          </tr>
        ) : null}

        {isDateEmpty(display.begin_date) ? null : (
          <tr>
            <th>{addColonText(l('Begin date'))}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        )}

        {isDateEmpty(display.end_date) ? null : (
          <tr>
            <th>{addColonText(l('End date'))}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        )}

        {nonEmpty(display.time) ? (
          <tr>
            <th>{addColonText(l('Time'))}</th>
            <td>{display.time}</td>
          </tr>
        ) : null}

        {display.setlist ? (
          <tr>
            <th>{addColonText(l('Setlist'))}</th>
            <td>{display.setlist}</td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default AddEvent;
