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

import Layout from '../layout';
import Tabs from '../components/Tabs';
import manifest from '../static/manifest';
import {l_statistics} from '../static/scripts/common/i18n/statistics';

import type {StatisticsLayoutPropsT} from './types';

const LinkStatisticsTab = (link: string, title: string) => (
  <span className="mp"><a href={link}>{title}</a></span>
);

const StatisticsLayout = ({children, fullWidth, page, title}: StatisticsLayoutPropsT) => {
  const htmlTitle = l_statistics('Database Statistics - {title}', {title: title});
  const infoLinks = [['index', LinkStatisticsTab('/statistics', l_statistics('Overview'))], ['countries', LinkStatisticsTab('/statistics/countries', l_statistics('Countries'))], ['languages-scripts', LinkStatisticsTab('/statistics/languages-scripts', l_statistics('Languages/Scripts'))], ['coverart', LinkStatisticsTab('/statistics/coverart', l_statistics('Cover Art'))], ['relationships', LinkStatisticsTab('/statistics/relationships', l_statistics('Relationships'))], ['edits', LinkStatisticsTab('/statistics/edits', l_statistics('Edits'))], ['formats', LinkStatisticsTab('/statistics/formats', l_statistics('Formats'))], ['editors', LinkStatisticsTab('/statistics/editors', l_statistics('Editors'))], ['timeline', LinkStatisticsTab('/statistics/timeline/main', l_statistics('Timeline'))]].map(link => link && <li className={link[0] === page ? 'sel' : ''}>{link[1]}</li>);
  return fullWidth ? (
    <Layout fullWidth title={htmlTitle}>
      {manifest.css('statistics')}
      <div className="statisticsheader">
        <h1>{l_statistics('Database Statistics')}</h1>
      </div>
      <Tabs>
        {infoLinks}
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
          {infoLinks}
        </Tabs>
        {children}
      </div>
      <div id="sidebar">
        {/* [%- sidebar -%] */}
      </div>
    </Layout>
  );
};

module.exports = StatisticsLayout;
