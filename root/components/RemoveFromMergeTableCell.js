/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../entities.mjs';
import {SanitizedCatalystContext} from '../context.mjs';
import {returnToCurrentPage} from '../utility/returnUri.js';

type Props = {
  +entity: CentralEntityT,
  +toMerge: $ReadOnlyArray<CentralEntityT>,
};

// Converted to react-table at root/utility/tableColumns.js
const RemoveFromMergeTableCell = ({
  entity,
  toMerge,
}: Props): React.Element<'td'> | null => {
  const $c = React.useContext(SanitizedCatalystContext);
  const url = ENTITIES[entity.entityType].url;
  return (
    toMerge.length > 2 ? (
      <td>
        <a
          href={
            `/${url}/merge?remove=${entity.id}&submit=remove&` +
            returnToCurrentPage($c)
          }
        >
          <button
            className="remove-item icon"
            title={l('Remove from merge')}
            type="button"
          />
        </a>
      </td>
    ) : null
  );
};

export default RemoveFromMergeTableCell;
