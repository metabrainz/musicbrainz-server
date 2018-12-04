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
import {l_statistics} from '../static/scripts/common/i18n/statistics';

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
    <span className="mp"><a href={link}>{title}</a></span>
  </li>
);

const infoLinks = [
  {link: '/statistics', page: 'index', title: l_statistics('Overview')},
  {link: '/statistics/countries', page: 'countries', title: l_statistics('Countries')},
  {link: '/statistics/languages-scripts', page: 'languages-scripts', title: l_statistics('Languages/Scripts')},
  {link: '/statistics/coverart', page: 'coverart', title: l_statistics('Cover Art')},
  {link: '/statistics/relationships', page: 'relationships', title: l_statistics('Relationships')},
  {link: '/statistics/edits', page: 'edits', title: l_statistics('Edits')},
  {link: '/statistics/formats', page: 'formats', title: l_statistics('Formats')},
  {link: '/statistics/editors', page: 'editors', title: l_statistics('Editors')},
  {link: '/statistics/timeline/main', page: 'timeline', title: l_statistics('Timeline')},
];

const StatisticsLayout = ({children, fullWidth, page, sidebar, title}: StatisticsLayoutPropsT) => {
  const htmlTitle = l_statistics('Database Statistics - {title}', {title: title});
  return fullWidth ? (
    <Layout fullWidth gettext_domains={['attributes', 'relationships', 'statistics']} title={htmlTitle}>
      {manifest.css('statistics')}
      <div className="statisticsheader">
        <h1>{l_statistics('Database Statistics')}</h1>
      </div>
      <Tabs>
        {infoLinks.map(props => (
          <LinkStatisticsTab {...props} key={props.page} selected={page} />
        ))}
      </Tabs>
      {children}
    </Layout>
  ) : (
    <Layout title={htmlTitle}>
      {manifest.css('statistics')}
      <div id="content">
        <div className="statisticsheader">
          <h1>{l_statistics('Database Statistics')}</h1>
        </div>
        <Tabs>
          {infoLinks.map(props => (
            <LinkStatisticsTab {...props} key={props.page} selected={page} />
          ))}
        </Tabs>
        {children}
      </div>
      <div id="sidebar">
        {sidebar}
      </div>
    </Layout>
  );
};

export default StatisticsLayout;
