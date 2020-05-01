/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationship
  from '../../static/scripts/common/components/Relationship';

type ReorderRelationshipsEditT = {
  ...EditT,
  +display_data: {
    +relationships: $ReadOnlyArray<{
      +new_order: number,
      +old_order: number,
      +relationship: RelationshipT,
    }>,
  },
};

type Props = {
  +edit: ReorderRelationshipsEditT,
};

const ReorderRelationships = ({edit}: Props): React.MixedElement => (
  <table className="details reorder-relationships">
    <tr>
      <th>{l('Relationship')}</th>
      <th>{l('Old Order')}</th>
      <th>{l('New Order')}</th>
    </tr>
    {edit.display_data.relationships.map((reorder, index) => (
      <tr key={index}>
        <td><Relationship relationship={reorder.relationship} /></td>
        <td className="old">{reorder.old_order}</td>
        <td className="new">{reorder.new_order}</td>
      </tr>
    ))}
  </table>
);

export default ReorderRelationships;
