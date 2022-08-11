/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../linkedEntities.mjs';

import DescriptiveLink from './DescriptiveLink.js';
import MediumDescription from './MediumDescription.js';

type Props = {
  +allowNew?: boolean,
  +medium: MediumT,
};

const MediumLink = ({allowNew, medium}: Props): Expand2ReactOutput => (
  exp.l('{medium} on {release}', {
    medium: <MediumDescription medium={medium} />,
    release: (
      <DescriptiveLink
        allowNew={allowNew}
        entity={linkedEntities.release[medium.release_id]}
      />
    ),
  })
);

export default MediumLink;
