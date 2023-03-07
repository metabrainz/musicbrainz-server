/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l_statistics as l} from '../static/scripts/common/i18n/statistics.js';

import StatisticsLayout from './StatisticsLayout.js';

const NoStatistics = (): React$Element<typeof StatisticsLayout> => (
  <StatisticsLayout fullWidth page="index" title={l('No Statistics')}>
    <h2>{l('No Statistics')}</h2>
    <p>
      {exp.l(
        `Statistics have never been collected for this server. If you are the
         administrator for this server, you should run
         <code>./admin/CollectStats.pl</code> or import
         <code>mbdump-stats.tar.bz2</code>.`,
      )}
    </p>
  </StatisticsLayout>
);

export default NoStatistics;
