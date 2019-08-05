import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import ExpandedArtistCredit from '../../components/ExpandedArtistCredit';

const AddReleaseGroup = ({edit}) => {
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Release Group:')}</th>
          <td>
            <DescriptiveLink entity={edit.display_data.release_group} />
          </td>
        </tr>
      </table>
      <table className="details add-release-group">
        <tr>
          <th>{l('Name:')}</th>
          <td>{edit.display_data.name}</td>
        </tr>

        <tr>
          <th>{l('Artist:')}</th>
          <td>
            <ExpandedArtistCredit ac={edit.display_data.artist_credit} />
          </td>
        </tr>

        {edit.display_data.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{edit.display_data.comment}</td>
          </tr>
        ) : null}

        {edit.display_data.type ? (
          <tr>
            <th>{l('Primary Type:')}</th>
            <td>{edit.display_data.type.name}</td>
          </tr>
        ) : null}

        {edit.display_data.secondary_types ? (
          <tr>
            <th>{l('Secondary Types:')}</th>
            <td>{edit.display_data.secondary_types}</td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default AddReleaseGroup;
