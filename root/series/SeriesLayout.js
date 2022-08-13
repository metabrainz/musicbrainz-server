/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import SeriesSidebar from '../layout/components/sidebar/SeriesSidebar.js';

import SeriesHeader from './SeriesHeader.js';

type Props = {
  +children: React.Node,
  +entity: SeriesT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const SeriesLayout = ({
  children,
  entity: series,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(series.name, title) : series.name}
  >
    <div id="content">
      <SeriesHeader page={page} series={series} />
      {children}
    </div>
    {fullWidth ? null : <SeriesSidebar series={series} />}
  </Layout>
);

export default SeriesLayout;
