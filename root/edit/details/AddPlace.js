/*
 * @flow
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import {formatCoordinates} from '../../utility/coordinates';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

type AddPlaceEditT = {
  ...EditT,
  +display_data: {
    ...DatePeriodRoleT,
    +address: string | null,
    +area: AreaT,
    +comment: string | null,
    +coordinates: CoordinatesT | null,
    +name?: string,
    +place: PlaceT,
    +type: PlaceTypeT | null,
  },
};

const AddPlace = ({edit}: {edit: AddPlaceEditT}) => {
  const display = edit.display_data;
  const type = display.type;
  const place = display.place;
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Place'))}</th>
            <td><DescriptiveLink entity={place} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details add-place">
        <tbody>
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
          {type ? (
            <tr>
              <th>{addColonText(l('Type'))}</th>
              <td>{lp_attributes(type.name, 'place_type')}</td>
            </tr>
          ) : null}
          {display.address ? (
            <tr>
              <th>{addColonText(l('Address'))}</th>
              <td>{display.address}</td>
            </tr>
          ) : null}
          {display.area ? (
            <tr>
              <th>{addColonText(l('Area'))}</th>
              <td><DescriptiveLink entity={display.area} /></td>
            </tr>
          ) : null}
          {display.coordinates ? (
            <tr>
              <th>{addColonText(l('Coordinates'))}</th>
              <td>{formatCoordinates(display.coordinates)}</td>
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
          <tr>
            <th>{addColonText(l('Ended'))}</th>
            <td>{yesNo(display.ended)}</td>
          </tr>
        </tbody>
      </table>
    </>
  );
};

export default AddPlace;
