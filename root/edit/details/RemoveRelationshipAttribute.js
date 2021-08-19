/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import IntentionallyRawIcon from '../components/IntentionallyRawIcon';

type RemoveRelationshipAttributeEditT = {
  ...EditT,
  +display_data: {
    +description: string | null,
    +name: string,
  },
};

type Props = {
  +edit: RemoveRelationshipAttributeEditT,
};

const RemoveRelationshipAttribute = ({
  edit,
}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <table className="details remove-relationship-attribute">
      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>
          {display.name}
          {rawIconSection}
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Description'))}</th>
        <td>
          {nonEmpty(display.description)
            ? (
              <>
                {display.description}
                {rawIconSection}
              </>
            ) : lp('(none)', 'description')}
        </td>
      </tr>
    </table>
  );
};

export default RemoveRelationshipAttribute;
