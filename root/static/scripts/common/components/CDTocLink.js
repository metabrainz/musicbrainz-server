/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../utility/entityHref';

type Props = {
  +anchorPath?: string,
  +cdToc: CDTocT,
  +content: string,
  +subPath?: string,
};

const CDTocLink = (
  {cdToc, content, subPath, anchorPath}: Props,
): React.Element<'a'> => (
  <a href={entityHref(cdToc, subPath, anchorPath)}>
    <bdi>
      {content}
    </bdi>
  </a>
);

export default CDTocLink;
