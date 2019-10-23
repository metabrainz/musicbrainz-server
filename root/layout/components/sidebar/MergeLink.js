/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';


type Props = {
  +entity: CoreEntityT,
};

const mergeUrl = entity => {
  const entityType = entity.entityType;
  const id = encodeURIComponent(String(entity.id));
  return `/${entityType}/merge_queue?add-to-merge=${id}`;
};

const MergeLink = ({entity}: Props) => (
  <li>
    <a href={mergeUrl(entity)}>
      {l('Merge')}
    </a>
  </li>
);

export default MergeLink;
