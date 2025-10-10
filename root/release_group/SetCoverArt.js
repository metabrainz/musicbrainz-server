/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import SetCoverArtForm
  from '../static/scripts/release-group/components/SetCoverArtForm.js';

import ReleaseGroupLayout from './ReleaseGroupLayout.js';
import {type SetCoverArtFormT} from './types.js';

component SetCoverArt(
  allReleases: $ReadOnlyArray<ReleaseT> = [],
  artwork: {[releaseId: number]: ArtworkT} = {},
  entity as releaseGroup: ReleaseGroupT,
  form?: SetCoverArtFormT,
) {
  return (
    <ReleaseGroupLayout
      entity={releaseGroup}
      fullWidth
      hasReleases={allReleases.length > 0}
      page="edit"
      title={lp('Set cover art', 'singular, header')}
    >
      <h2>{lp('Set cover art', 'singular, header')}</h2>

      {Object.keys(artwork).length && form ? (
        <SetCoverArtForm
          allReleases={allReleases}
          artwork={artwork}
          form={form}
        />
      ) : (
        <p>
          {l(`No releases have cover art marked as "Front",
              cannot set cover art.`)}
        </p>
      )}
      {manifest(
        'release-group/components/SetCoverArtForm',
        {async: true},
      )}
      {manifest('common/artworkViewer', {async: true})}
    </ReleaseGroupLayout>
  );
}

export default SetCoverArt;
