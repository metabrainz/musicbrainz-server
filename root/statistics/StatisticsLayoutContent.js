/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Tabs from '../components/Tabs';
import {unwrapNl} from '../static/scripts/common/i18n';

export type StatisticsLayoutContentPropsT = {
  +children: React.Node,
  +fullWidth?: boolean,
  +page: string,
  +sidebar?: ?React.Node,
};

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

const StatisticsLayoutTabs = React.memo(({page}) => (
  <Tabs>
    {infoLinks.map(props => (
      <LinkStatisticsTab {...props} key={props.page} selected={page} />
    ))}
  </Tabs>
));

const StatisticsLayoutContent = ({
  children,
  fullWidth = false,
  page,
  sidebar,
}: StatisticsLayoutContentPropsT): React.MixedElement => (
  <>
    <link
      href={require('../static/styles/statistics.less')}
      rel="stylesheet"
      type="text/css"
    />
    <div id="content">
      <div className="statisticsheader">
        <h1>{l('Database Statistics')}</h1>
      </div>
      <StatisticsLayoutTabs page={page} />
      {children}
    </div>
    {fullWidth ? null : <div id="sidebar">{sidebar}</div>}
  </>
);

export default StatisticsLayoutContent;
