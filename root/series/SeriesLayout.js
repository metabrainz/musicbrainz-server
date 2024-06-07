/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SeriesSidebar from '../layout/components/sidebar/SeriesSidebar.js';
import Layout from '../layout/index.js';

import SeriesHeader from './SeriesHeader.js';

component SeriesLayout(
  children: React.Node,
  entity as series: SeriesT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
    <Layout
      title={nonEmpty(title)
        ? hyphenateTitle(series.name, title)
        : series.name}
    >
      <div id="content">
        <SeriesHeader page={page} series={series} />
        {children}
      </div>
      {fullWidth ? null : <SeriesSidebar series={series} />}
    </Layout>
  );
}

export default SeriesLayout;
