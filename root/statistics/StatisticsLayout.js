/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import Tabs from '../components/Tabs';
import {unwrapNl} from '../static/scripts/common/i18n';
import {l_statistics as l, N_l_statistics as N_l}
  from '../static/scripts/common/i18n/statistics';

type StatisticsLayoutPropsT = {
  +children: ReactNode,
  +fullWidth: boolean,
  +page: string,
  +sidebar?: ?ReactNode,
  +title: string,
};

type TabPropsT = {
  +link: string,
  +page: string,
  +selected: string,
  +title: string | (() => string | React$MixedElement),
};

const LinkStatisticsTab = ({link, title, page, selected}: TabPropsT) => (
  <li className={page === selected ? 'sel' : ''}>
    <a href={link}>
      {unwrapNl<string | React$MixedElement>(title)}
    </a>
  </li>
);

const infoLinks = [
  {
    link: '/statistics',
    page: 'index',
    title: N_l('Overview'),
  },
  {
    link: '/statistics/countries',
    page: 'countries',
    title: N_l('Countries'),
  },
  {
    link: '/statistics/languages-scripts',
    page: 'languages-scripts',
    title: N_l('Languages/Scripts'),
  },
  {
    link: '/statistics/coverart',
    page: 'coverart',
    title: N_l('Cover Art'),
  },
  {
    link: '/statistics/relationships',
    page: 'relationships',
    title: N_l('Relationships'),
  },
  {
    link: '/statistics/edits',
    page: 'edits',
    title: N_l('Edits'),
  },
  {
    link: '/statistics/formats',
    page: 'formats',
    title: N_l('Formats'),
  },
  {
    link: '/statistics/editors',
    page: 'editors',
    title: N_l('Editors'),
  },
  {
    link: '/statistics/timeline/main',
    page: 'timeline',
    title: N_l('Timeline'),
  },
];

const StatisticsLayout = ({
  children,
  fullWidth,
  page,
  sidebar,
  title,
}: StatisticsLayoutPropsT) => {
  const htmlTitle = hyphenateTitle(l('Database Statistics'), title);
  return (
    <Layout
      fullWidth={fullWidth}
      title={htmlTitle}
    >
      <link
        href={require('../static/styles/statistics.less')}
        rel="stylesheet"
        type="text/css"
      />
      <div id="content">
        <div className="statisticsheader">
          <h1>{l('Database Statistics')}</h1>
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
};

export default StatisticsLayout;
