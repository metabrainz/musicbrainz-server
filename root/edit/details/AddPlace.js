import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import { formatCoordinates } from '../../utility/coordinates';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

const AddPlace = ({edit}) => {
  console.log(edit);
  console.log(edit.display_data.area);
  const display = edit.display_data;
  const entity = display["place"];
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Place:')}</th>
          <td><DescriptiveLink entity={entity} /></td>
        </tr>
      </table>
      <table className="details add-place">
        <tr>
          <th>{l('Name:')}</th>
          <td>{display.name}</td>
        </tr>
        {display.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ): null}
        {display.type ? (
          <tr>
            <th>{l('Type:')}</th>
            <td>{display.type.name}</td>
          </tr>
        ): null}
        {display.address ? (
          <tr>
            <th>{l('Address:')}</th>
            <td>{display.address}</td>
          </tr>
        ): null}
        {display.area ? (
          <tr>
            <th>{l('Area:')}</th>
            <td><DescriptiveLink entity={display.area} /></td>
          </tr>
        ): null}
        {display.coordinates ? (
          <tr>
            <th>{l('Coordinates:')}</th>
            <td>{formatCoordinates(display.coordinates)}</td>
          </tr>
        ): null}
        {isDateEmpty(display.begin_date) ? null : (
          <tr>
            <th>{l('Begin date:')}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        )}
        {isDateEmpty(display.end_date) ? null : (
          <tr>
            <th>{l('End date:')}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        )}

        <tr>
          <th>{l('Ended:')}</th>
          <td>{yesNo(display.ended)}</td>
        </tr>
      </table>
    </>
  );
};

export default AddPlace;
