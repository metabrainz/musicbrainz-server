/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseGroupSidebar
  from '../layout/components/sidebar/ReleaseGroupSidebar.js';
import Layout from '../layout/index.js';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities.js';

import ReleaseGroupHeader from './ReleaseGroupHeader.js';

component ReleaseGroupLayout(
  children: React$Node,
  entity as releaseGroup: ReleaseGroupT,
  firstReleaseGid?: string | null,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  const mainTitle = texp.l('Release group “{name}” by {artist}', {
    artist: reduceArtistCredit(releaseGroup.artistCredit),
    name: releaseGroup.name,
  });
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(mainTitle, title) : mainTitle}
    >
      <div id="content">
        <ReleaseGroupHeader page={page} releaseGroup={releaseGroup} />
        {children}
      </div>
      {fullWidth ? null : (
        <ReleaseGroupSidebar
          firstReleaseGid={firstReleaseGid}
          releaseGroup={releaseGroup}
        />
      )}
    </Layout>
  );
}

export default ReleaseGroupLayout;
