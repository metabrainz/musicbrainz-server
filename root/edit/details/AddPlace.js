/*
 * @flow strict-local
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty.js';
import {formatCoordinates} from '../../utility/coordinates.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';

type Props = {
  +edit: AddPlaceEditT,
};

const AddPlace = ({edit}: Props): React.MixedElement => {
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
          {nonEmpty(display.comment) ? (
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
          {nonEmpty(display.address) ? (
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
