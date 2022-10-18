/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationship
  from '../../static/scripts/common/components/Relationship.js';

type Props = {
  +edit: AddRelationshipEditT,
};

const AddRelationship = ({edit}: Props): React.MixedElement => {
  const relationship = {
    ...edit.display_data.relationship,
    entity0: edit.display_data.entity0,
    entity1: edit.display_data.entity1,
  };
  return (
    <table className="details add-relationship">
      <tr>
        <th>{l('Relationship:')}</th>
        <td>
          <Relationship
            allowNewEntity0={!edit.display_data.entity0?.id}
            allowNewEntity1={!edit.display_data.entity1?.id}
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
