import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';

const AddPlace = ({edit}) => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const entity = display[entityType];
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Place:')}</th>
          <td>
            <DescriptiveLink entity={entity} />
          </td>
        </tr>
      </table>
      <table />
    </>
  );
};

export default AddPlace;
