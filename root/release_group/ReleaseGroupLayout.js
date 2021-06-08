/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import ReleaseGroupSidebar
  from '../layout/components/sidebar/ReleaseGroupSidebar';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities';

import ReleaseGroupHeader from './ReleaseGroupHeader';

type Props = {
  +$c: CatalystContextT,
  +children: React.Node,
  +entity: ReleaseGroupT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const ReleaseGroupLayout = ({
  children,
  entity: releaseGroup,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => {
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
      {fullWidth ? null : <ReleaseGroupSidebar releaseGroup={releaseGroup} />}
    </Layout>
  );
};

export default ReleaseGroupLayout;
