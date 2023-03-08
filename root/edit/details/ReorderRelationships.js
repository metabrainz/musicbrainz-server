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
  +edit: ReorderRelationshipsEditT,
};

const ReorderRelationships = ({edit}: Props): React$MixedElement => (
  <table className="details reorder-relationships">
    <tr>
      <th className="align-left wide">{l('Relationship')}</th>
      <th className="narrow">{l('Old Order')}</th>
      <th className="narrow">{l('New Order')}</th>
    </tr>
    {edit.display_data.relationships.map((reorder, index) => (
      <tr key={index}>
        <td className="wide">
          <Relationship relationship={reorder.relationship} />
        </td>
        <td className="align-right narrow old">{reorder.old_order}</td>
        <td className="align-right narrow new">{reorder.new_order}</td>
      </tr>
    ))}
  </table>
);

export default ReorderRelationships;
