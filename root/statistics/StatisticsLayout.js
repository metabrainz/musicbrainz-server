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
import manifest from '../static/manifest';
import {hyphenateTitle} from '../static/scripts/common/i18n';
import {l_statistics as l} from '../static/scripts/common/i18n/statistics';

type StatisticsLayoutPropsT = {|
  +children: ReactNode,
  +fullWidth: boolean,
  +page: string,
  +sidebar?: ?ReactNode,
  +title: string,
|};

type TabPropsT = {
  +link: string,
  +page: string,
  +selected: string,
  +title: string,
};

const LinkStatisticsTab = ({link, title, page, selected}: TabPropsT) => (
  <li className={page === selected ? 'sel' : ''}>
    <a href={link}>{title}</a>
  </li>
);

const infoLinks = [
  {link: '/statistics', page: 'index', title: l('Overview')},
  {link: '/statistics/countries', page: 'countries', title: l('Countries')},
  {link: '/statistics/languages-scripts', page: 'languages-scripts', title: l('Languages/Scripts')},
  {link: '/statistics/coverart', page: 'coverart', title: l('Cover Art')},
  {link: '/statistics/relationships', page: 'relationships', title: l('Relationships')},
  {link: '/statistics/edits', page: 'edits', title: l('Edits')},
  {link: '/statistics/formats', page: 'formats', title: l('Formats')},
  {link: '/statistics/editors', page: 'editors', title: l('Editors')},
  {link: '/statistics/timeline/main', page: 'timeline', title: l('Timeline')},
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
    <Layout fullWidth={fullWidth} gettext_domains={['attributes', 'relationships', 'statistics']} title={htmlTitle}>
      {manifest.css('statistics')}
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
