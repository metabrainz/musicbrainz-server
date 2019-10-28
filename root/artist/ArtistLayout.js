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
import ArtistSidebar from '../layout/components/sidebar/ArtistSidebar';

import ArtistHeader from './ArtistHeader';

type Props = {
  +children: ReactNode,
  +entity: ArtistT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const ArtistLayout = ({
  children,
  entity: artist,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title ? hyphenateTitle(artist.name, title) : artist.name}
  >
    <div id="content">
      <ArtistHeader artist={artist} page={page} />
      {children}
    </div>
    {fullWidth ? null : <ArtistSidebar artist={artist} />}
  </Layout>
);


export default ArtistLayout;
