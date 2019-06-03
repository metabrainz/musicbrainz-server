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
import GenreSidebar from '../layout/components/sidebar/GenreSidebar';

import GenreHeader from './GenreHeader';

type Props = {|
  +children: ReactNode,
  +entity: GenreT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const GenreLayout = ({
  children,
  entity: genre,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title}
  >
    <div id="content">
      <GenreHeader genre={genre} page={page} />
      {children}
    </div>
    {fullWidth ? null : <GenreSidebar genre={genre} />}
  </Layout>
);


export default GenreLayout;
