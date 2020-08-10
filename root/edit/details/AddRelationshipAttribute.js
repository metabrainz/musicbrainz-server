/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type AddRelationshipAttributeEditT = {
  ...EditT,
  +display_data: {
    +child_order: number,
    +description: string | null,
    +name: string,
    +parent?: LinkAttrTypeT,
  },
};

type Props = {
  +edit: AddRelationshipAttributeEditT,
};

const AddRelationshipAttribute = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const parent = display.parent;

  return (
    <table className="details add-relationship-attribute">
      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>{display.name}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Description'))}</th>
        <td>{display.description}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Child order'))}</th>
        <td>{display.child_order}</td>
      </tr>
      {parent ? (
        <tr>
          <th>{addColonText(l('Parent'))}</th>
          <td>{l_relationships(parent.name)}</td>
        </tr>
      ) : null}
    </table>
  );
};

export default AddRelationshipAttribute;
