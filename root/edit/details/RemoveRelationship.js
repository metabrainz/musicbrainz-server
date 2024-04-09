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

component RemoveRelationship(edit: RemoveRelationshipEditT) {
  return (
    <table className="details remove-relationship">
      <tr>
        <th>{addColonText(l('Relationship'))}</th>
        <td>
          <Relationship relationship={edit.display_data.relationship} />
        </td>
      </tr>
    </table>
  );
}

export default RemoveRelationship;
