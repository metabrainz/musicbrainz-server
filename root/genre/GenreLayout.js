/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import GenreSidebar from '../layout/components/sidebar/GenreSidebar.js';
import Layout from '../layout/index.js';

import GenreHeader from './GenreHeader.js';

component GenreLayout(
  children: React$Node,
  entity as genre: GenreT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
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
}


export default GenreLayout;
