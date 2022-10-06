/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from './EntityLink.js';

const buildAppearancesRow = (releaseGroup: ReleaseGroupT) => (
  <li key={releaseGroup.id}>
    <EntityLink entity={releaseGroup} />
  </li>
);

type ReleaseGroupAppearancesProps = {
  +appearances: ReleaseGroupAppearancesT,
};

const ReleaseGroupAppearances = (
  {appearances}: ReleaseGroupAppearancesProps,
): React.Element<'ul'> | null => {
  const releaseGroups = appearances.results;
  const unloadedReleaseGroupCount = appearances.hits - releaseGroups.length;
  return (
    (appearances && releaseGroups.length > 0) ? (
      <ul>
        {releaseGroups.map(
          releaseGroup => buildAppearancesRow(releaseGroup),
        )}
        {unloadedReleaseGroupCount ? (
          <li>
            {exp.ln(
              'and another {num} release group',
              'and another {num} release groups',
              unloadedReleaseGroupCount,
              {num: unloadedReleaseGroupCount},
            )}
          </li>
        ) : null}
      </ul>
    ) : null
  );
};

export default ReleaseGroupAppearances;
