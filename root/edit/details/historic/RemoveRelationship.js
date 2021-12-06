/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {HistoricRelationship}
  from '../../../static/scripts/common/components/Relationship';

type Props = {
  +edit: RemoveRelationshipHistoricEditT,
};

const RemoveRelationship = ({edit}: Props): React.Element<'table'> => (
  <table className="details remove-relationship-historic">
    <tr>
      {edit.display_data.relationships.length ? (
        <>
          <th>{l('Relationships:')}</th>
          <td>
            <ul>
              {edit.display_data.relationships.map(relationship => (
                <li key={relationship.id}>
                  <HistoricRelationship relationship={relationship} />
                </li>
              ))}
            </ul>
          </td>
        </>
      ) : (
        <td>
          {l('An error occurred while loading this edit.')}
        </td>
      )}
    </tr>
  </table>
);

export default RemoveRelationship;
