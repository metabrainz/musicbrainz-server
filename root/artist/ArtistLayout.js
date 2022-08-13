/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistSidebar from '../layout/components/sidebar/ArtistSidebar.js';
import Layout from '../layout/index.js';

import ArtistHeader from './ArtistHeader.js';

type Props = {
  +children: React.Node,
  +entity: ArtistT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const ArtistLayout = ({
  children,
  entity: artist,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(artist.name, title) : artist.name}
  >
    <div id="content">
      <ArtistHeader artist={artist} page={page} />
      {children}
    </div>
    {fullWidth ? null : <ArtistSidebar artist={artist} />}
  </Layout>
);

export default ArtistLayout;
