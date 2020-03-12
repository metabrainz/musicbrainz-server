/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const RemoveFromMergeTableHeader = (
  {toMerge}: {toMerge: $ReadOnlyArray<CoreEntityT>},
) => (
  toMerge.length > 2 ? (
    <th aria-label={l('Remove from merge')} style={{width: '1em'}} />
  ) : null
);

export default RemoveFromMergeTableHeader;
