/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import GenreSidebar from '../layout/components/sidebar/GenreSidebar.js';
import Layout from '../layout/index.js';

import GenreHeader from './GenreHeader.js';

type Props = {
  +children: React.Node,
  +entity: GenreT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const GenreLayout = ({
  children,
  entity: genre,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(genre.name, title) : genre.name}
  >
    <div id="content">
      <GenreHeader genre={genre} page={page} />
      {children}
    </div>
    {fullWidth ? null : <GenreSidebar genre={genre} />}
  </Layout>
);


export default GenreLayout;
