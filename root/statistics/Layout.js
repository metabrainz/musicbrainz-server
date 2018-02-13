/*
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const Layout = require('../layout');
const Tabs = require('../components/Tabs');
const manifest = require('../static/manifest');
const {l} = require('../static/scripts/common/i18n');

const LinkStatisticsTab = (link, title) => (
  <span className="mp"><a href={link}>{title}</a></span>
);

const StatisticsLayout = ({title, fullWidth, page, children}) => {
  const htmlTitle = l('Database Statistics - {title}', {title: title});
  const infoLinks = [['index', LinkStatisticsTab('/statistics', l('Overview'))], ['countries', LinkStatisticsTab('/statistics/countries', l('Countries'))], ['languages-scripts', LinkStatisticsTab('/statistics/languages-scripts', l('Languages/Scripts'))], ['coverart', LinkStatisticsTab('/statistics/coverart', l('Cover Art'))], ['relationships', LinkStatisticsTab('/statistics/relationships', l('Relationships'))], ['edits', LinkStatisticsTab('/statistics/edits', l('Edits'))], ['formats', LinkStatisticsTab('/statistics/formats', l('Formats'))], ['editors', LinkStatisticsTab('/statistics/editors', l('Editors'))], ['timeline', LinkStatisticsTab('/statistics/timeline/main', l('Timeline'))]].map(link => link && <li className={link[0] === page ? 'sel' : ''}>{link[1]}</li>);
  return fullWidth ? (
    <Layout fullWidth title={htmlTitle}>
      {manifest.css('statistics')}
      <div className="statisticsheader">
        <h1>{l('Database Statistics')}</h1>
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
          <h1>{l('Database Statistics')}</h1>
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
