import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';

const AddSeries = ({edit}) => {
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{l('Series:')}</th>
            <td><EntityLink entity={edit.display_data.series} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details add-series">
        <tbody>
          <tr>
            <th>{l('Name:')}</th>
            <td>{edit.display_data.name}</td>
          </tr>
          {edit.display_data.comment ? (
            <tr>
              <th>{addColon(l('Disambiguation'))}</th>
              <td>{edit.display_data.comment}</td>
            </tr>
          ) : null}
          {edit.display_data.type ? (
            <tr>
              <th>{l('Type:')}</th>
              <td>{edit.display_data.type.name}</td>
            </tr>
          ) : null}
          {edit.display_data.ordering_type ? (
            <tr>
              <th>{l('Ordering Type:')}</th>
              <td>{edit.display_data.ordering_type.name}</td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddSeries;
