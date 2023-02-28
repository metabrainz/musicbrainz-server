/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../utility/entityHref.js';

type Props = {
  +cdstub: CDStubT,
  +content: string,
  +subPath?: string,
};

const CDStubLink = ({
  cdstub,
  content,
  subPath,
}: Props): React.Element<'a'> => (
  <a href={entityHref(cdstub, subPath)}>
    <bdi>
      {content}
    </bdi>
  </a>
);

export default CDStubLink;
