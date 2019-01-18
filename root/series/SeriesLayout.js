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
import SeriesSidebar from '../layout/components/sidebar/SeriesSidebar';
import {hyphenateTitle} from '../static/scripts/common/i18n';

import SeriesHeader from './SeriesHeader';

type Props = {|
  +children: ReactNode,
  +entity: SeriesT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const SeriesLayout = ({
  children,
  entity: series,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title ? hyphenateTitle(series.name, title) : series.name}
  >
    <div id="content">
      <SeriesHeader page={page} series={series} />
      {children}
    </div>
    {fullWidth ? null : <SeriesSidebar series={series} />}
  </Layout>
);


export default SeriesLayout;
