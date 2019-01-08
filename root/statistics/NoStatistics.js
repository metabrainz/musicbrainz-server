/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l_statistics} from '../static/scripts/common/i18n/statistics';

import StatisticsLayout from './StatisticsLayout';

const NoStatistics = () => (
  <StatisticsLayout fullWidth page="index" title={l_statistics('No Statistics')}>
    <h2>{l_statistics('No Statistics')}</h2>
    <p>
      {l_statistics('Statistics have never been collected for this server. If you are the \
           administrator for this server, you should run \
           <code>./admin/CollectStats.pl</code> or import \
           <code>mbdump-stats.tar.bz2</code>.', {__react: true})}
    </p>
  </StatisticsLayout>
);

export default NoStatistics;
