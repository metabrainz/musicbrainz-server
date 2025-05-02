/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import RelationshipDiff
  from '../../static/scripts/edit/components/edit/RelationshipDiff.js';

component EditRelationship(edit: EditRelationshipEditT) {
  return (
    <table className="details edit-relationship">
      <RelationshipDiff
        newRelationship={edit.display_data.new}
        oldRelationship={edit.display_data.old}
        showTooltip
      />
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
}

export default EditRelationship;
