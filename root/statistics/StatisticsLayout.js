/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Tabs from '../components/Tabs.js';
import Layout from '../layout/index.js';
import {unwrapNl} from '../static/scripts/common/i18n.js';
import statisticsLessUrl from '../static/styles/statistics.less';

component LinkStatisticsTab(
  link: string,
  page: string,
  selected: string,
  title: string | (() => string | React$MixedElement),
) {
  return (
    <li className={page === selected ? 'sel' : ''}>
      <a href={link}>
        {unwrapNl<string | React$MixedElement>(title)}
      </a>
    </li>
  );
}

const infoLinks = [
  {
    link: '/statistics',
    page: 'index',
    title: N_l_statistics('Overview'),
  },
  {
    link: '/statistics/countries',
    page: 'countries',
    title: N_l_statistics('Countries'),
  },
  {
    link: '/statistics/languages-scripts',
    page: 'languages-scripts',
    title: N_l_statistics('Languages/Scripts'),
  },
  {
    link: '/statistics/images',
    page: 'images',
    title: N_l_statistics('Images'),
  },
  {
    link: '/statistics/relationships',
    page: 'relationships',
    title: N_l_statistics('Relationships'),
  },
  {
    link: '/statistics/edits',
    page: 'edits',
    title: N_l_statistics('Edits'),
  },
  {
    link: '/statistics/formats',
    page: 'formats',
    title: N_l_statistics('Formats'),
  },
  {
    link: '/statistics/editors',
    page: 'editors',
    title: N_l_statistics('Editors'),
  },
  {
    link: '/statistics/timeline/main',
    page: 'timeline',
    title: N_l_statistics('Timeline'),
  },
];

component StatisticsLayout(
  children: React$Node,
  fullWidth: boolean = false,
  page: string,
  sidebar?: ?React$Node,
  title: string,
) {
  const htmlTitle = hyphenateTitle(l_statistics('Database statistics'),
                                   title);
  return (
    <Layout
      fullWidth={fullWidth}
      title={htmlTitle}
    >
      <link
        href={statisticsLessUrl}
        rel="stylesheet"
        type="text/css"
      />
      <div id="content">
        <div className="statisticsheader">
          <h1>{l_statistics('Database statistics')}</h1>
        </div>
        <Tabs>
          {infoLinks.map(props => (
            <LinkStatisticsTab {...props} key={props.page} selected={page} />
          ))}
        </Tabs>
        {children}
      </div>
      {fullWidth ? null : <div id="sidebar">{sidebar}</div>}
    </Layout>
  );
}

export default StatisticsLayout;
