/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseLayout from './ReleaseLayout';

type Props = {
  +release: ReleaseT,
};

const CoverArtDarkened = ({
  release,
}: Props): React.Element<typeof ReleaseLayout> => {
  const title = l('Cannot Add Cover Art');

  return (
    <ReleaseLayout entity={release} page="cover-art" title={title}>
      <h2>{title}</h2>
      <p>
        {l(`The Cover Art Archive has had a takedown request in the past
            for this release, so we are unable to allow any more uploads.`)}
      </p>
    </ReleaseLayout>
  );
};

export default CoverArtDarkened;
