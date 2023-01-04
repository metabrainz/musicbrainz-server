/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../utility/entityHref.js';

type Props = {
  +anchorPath?: string,
  +cdToc: {
    +discid: string,
    +entityType: 'cdtoc',
    ...
  },
  +content?: string,
  +subPath?: string,
};

const CDTocLink = (
  {cdToc, content, subPath, anchorPath}: Props,
): React.Element<'a'> => (
  <a href={entityHref(cdToc, subPath, anchorPath)}>
    <bdi>
      {nonEmpty(content) ? content : cdToc.discid}
    </bdi>
  </a>
);

export default CDTocLink;
