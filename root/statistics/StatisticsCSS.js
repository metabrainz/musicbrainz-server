/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import statisticsLessUrl from '../static/styles/statistics.less';

const StatisticsCSS = (): React$Element<'link'> => (
  <link
    href={statisticsLessUrl}
    rel="stylesheet"
    type="text/css"
  />
);

export default StatisticsCSS;
