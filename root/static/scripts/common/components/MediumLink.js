/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities from '../linkedEntities';

import DescriptiveLink from './DescriptiveLink';
import MediumDescription from './MediumDescription';

const MediumLink = ({medium}: {+medium: MediumT}): Expand2ReactOutput => (
  exp.l('{medium} on {release}', {
    medium: <MediumDescription medium={medium} />,
    release: (
      <DescriptiveLink
        entity={linkedEntities.release[medium.release_id]}
      />
    ),
  })
);

export default MediumLink;
