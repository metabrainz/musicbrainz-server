/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import {hyphenateTitle, l} from '../static/scripts/common/i18n';
import ReleaseGroupSidebar from '../layout/components/sidebar/ReleaseGroupSidebar';
import {artistCreditFromArray, reduceArtistCredit} from '../static/scripts/common/immutable-entities';

import ReleaseGroupHeader from './ReleaseGroupHeader';

type Props = {|
  +children: ReactNode,
  +entity: ReleaseGroupT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const ReleaseGroupLayout = ({
  children,
  entity: releaseGroup,
  fullWidth,
  page,
  title,
}: Props) => {
  const mainTitle = l('Release group “{name}” by {artist}', {
    artist: reduceArtistCredit(
      artistCreditFromArray(releaseGroup.artistCredit),
    ),
    name: releaseGroup.name,
  });
  return (
    <Layout title={title ? hyphenateTitle(mainTitle, title) : mainTitle}>
      <div id="content">
        <ReleaseGroupHeader page={page} releaseGroup={releaseGroup} />
        {children}
      </div>
      {fullWidth ? null : <ReleaseGroupSidebar releaseGroup={releaseGroup} />}
    </Layout>
  );
};

export default ReleaseGroupLayout;
