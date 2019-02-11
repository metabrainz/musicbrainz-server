/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import {hyphenateTitle, l, TEXT} from '../static/scripts/common/i18n';
import ReleaseSidebar from '../layout/components/sidebar/ReleaseSidebar';
import {artistCreditFromArray, reduceArtistCredit} from '../static/scripts/common/immutable-entities';

import ReleaseHeader from './ReleaseHeader';

type Props = {|
  +children: ReactNode,
  +entity: ReleaseT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const ReleaseLayout = ({
  children,
  entity: release,
  fullWidth,
  page,
  title,
}: Props) => {
  const mainTitle = l('Release “{name}” by {artist}', {
    artist: reduceArtistCredit(
      artistCreditFromArray(release.artistCredit),
    ),
    name: release.name,
  }, TEXT);
  return (
    <Layout title={title ? hyphenateTitle(mainTitle, title) : mainTitle}>
      <div id="content">
        <ReleaseHeader page={page} release={release} />
        {children}
      </div>
      {fullWidth ? null : <ReleaseSidebar release={release} />}
    </Layout>
  );
};

export default ReleaseLayout;
