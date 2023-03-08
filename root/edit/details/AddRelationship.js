/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Relationship
  from '../../static/scripts/common/components/Relationship.js';

type Props = {
  +edit: AddRelationshipEditT,
};

const AddRelationship = ({edit}: Props): React$MixedElement => {
  const relationship = edit.display_data.relationship;
  return (
    <table className="details add-relationship">
      <tr>
        <th>{l('Relationship:')}</th>
        <td>
          <Relationship
            allowNewEntity0={relationship.entity0_id === 0}
            allowNewEntity1={relationship.entity1_id === 0}
            relationship={relationship}
          />
        </td>
      </tr>
      {edit.display_data.relationship.linkOrder ? (
        <tr>
          <th>{l('Link order:')}</th>
          <td>{edit.display_data.relationship.linkOrder}</td>
        </tr>
      ) : null}
      {edit.display_data.unknown_attributes ? (
        <tr>
          <th />
          <td>
            {l(`This relationship edit also included changes
                to relationship attributes which no longer exist.`)}
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default AddRelationship;
