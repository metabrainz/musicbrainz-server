/*
 * @flow strict-local
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import {l_statistics as l, N_l_statistics as N_l}
  from '../static/scripts/common/i18n/statistics';

import StatisticsLayoutContent, {
  type StatisticsLayoutContentPropsT,
} from './StatisticsLayoutContent';

type StatisticsLayoutPropsT = $ReadOnly<{
  ...StatisticsLayoutContentPropsT,
  +$c: CatalystContextT,
  +title: string,
}>;

const StatisticsLayout = ({
  $c,
  children,
  fullWidth = false,
  page,
  sidebar,
  title,
}: StatisticsLayoutPropsT): React.Element<typeof Layout> => {
  const htmlTitle = hyphenateTitle(l('Database Statistics'), title);
  return (
    <Layout
      $c={$c}
      fullWidth={fullWidth}
      title={htmlTitle}
    >
      <StatisticsLayoutContent
        fullWidth={fullWidth}
        page={page}
        sidebar={sidebar}
      >
        {children}
      </StatisticsLayoutContent>
    </Layout>
  );
};

export default StatisticsLayout;
