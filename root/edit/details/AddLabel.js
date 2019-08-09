import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatIsni from '../../utility/formatIsni';

const AddLabel = ({edit}) => {
  const display = edit.display_data;
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Label:')}</th>
          <td><EntityLink entity={display.label} /></td>
        </tr>
      </table>
      <table className="details add-label">
        <tr>
          <th>{l('Name:')}</th>
          <td>{display.name}</td>
        </tr>
        {display.sort_name ? (
          <tr>
            <th>{l('Sort name:')}</th>
            <td>{display.sort_name}</td>
          </tr>
        ) : null}
        {display.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}
        {isDateEmpty(display.begin_date) ? (
          <tr>
            <th>{l('Begin date:')}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        ) : null}
        {isDateEmpty(display.end_date) ? (
          <tr>
            <th>{l('End date:')}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        ) : null}
        <tr>
          <th>{l('Ended:')}</th>
          <td>{yesNo(display.ended)}</td>
        </tr>
        {display.area ? (
          <tr>
            <th>{l('Area:')}</th>
            <td><DescriptiveLink entity={display.area} /></td>
          </tr>
        ) : null}
        {display.type ? (
          <tr>
            <th>{l('Type:')}</th>
            <td>{display.type.name}</td>
          </tr>
        ) : null}
        {display.label_code ? (
          <tr>
            <th>{l('Label code:')}</th>
            <td>{display.label_code}</td>
          </tr>
        ) : null}
        {display.ipi_codes.length > 0
          ? display.ipi_codes.forEach(ipiCode => (
            <tr>
              <th>{l('IPI code:')}</th>
              <td>{ipiCode}</td>
            </tr>
          )) : null}
        {display.isni_codes.length > 0
          ? display.isni_codes.forEach(isniCode => (
            <tr>
              <th>{l('ISNI code:')}</th>
              <td>{formatIsni(isniCode)}</td>
            </tr>
          )) : null}
      </table>
    </>
  );
};

export default AddLabel;
