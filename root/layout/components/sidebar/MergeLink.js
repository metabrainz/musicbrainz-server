/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import {returnToCurrentPage} from '../../../utility/returnUri.js';

const mergeUrl = (
  $c: CatalystContextT,
  entity: MergeableEntityT,
) => {
  const entityType = entity.entityType;
  const id = encodeURIComponent(String(entity.id));
  return `/${entityType}/merge_queue?add-to-merge=${id}&` +
    returnToCurrentPage($c);
};

component MergeLink(entity: MergeableEntityT) {
  const $c = React.useContext(CatalystContext);
  return (
    <li>
      <a href={mergeUrl($c, entity)}>
        {lp('Merge', 'interactive')}
      </a>
    </li>
  );
}

export default MergeLink;
