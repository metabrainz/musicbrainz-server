/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseSidebar from '../layout/components/sidebar/ReleaseSidebar.js';
import Layout from '../layout/index.js';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities.js';

import ReleaseHeader from './ReleaseHeader.js';

component ReleaseLayout(
  children: React.Node,
  entity as release: ReleaseT,
  fullWidth: boolean = false,
  page?: string,
  title?: string,
) {
  const mainTitle = texp.l('Release “{name}” by {artist}', {
    artist: reduceArtistCredit(release.artistCredit),
    name: release.name,
  });
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(mainTitle, title) : mainTitle}
    >
      <div id="content">
        <ReleaseHeader page={page} release={release} />
        {children}
      </div>
      {fullWidth ? null : <ReleaseSidebar release={release} />}
    </Layout>
  );
}

export default ReleaseLayout;
