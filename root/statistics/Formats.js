/*
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const Layout = require('./Layout');
const {formatCount, formatPercentage, LinkSearchableProperty} = require('./utilities');
const {l} = require('../static/scripts/common/i18n');

const Formats = () => {
  const stats = $c.stash.stats;
  const formatStats = $c.stash.format_stats;
  return (
    <Layout fullWidth page="formats" title={l('Release/Medium Formats')}>
      <p>{l('Last updated: {date}',
        {__react: true, date: stats.date_collected})}
      </p>
      <h2>{l('Release/Medium Formats')}</h2>
      <table className="tbl">
        <thead>
          <tr>
            <th className="pos">{l('Rank')}</th>
            <th>{l('Format')}</th>
            <th>{l('Releases')}</th>
            <th>{l('% of total releases')}</th>
            <th>{l('Mediums')}</th>
            <th>{l('% of total mediums')}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td />
            <td>{l('Total')}</td>
            <td className="t">{formatCount(stats.data['count.release'])}</td>
            <td className="t">{l('100%')}</td>
            <td className="t">{formatCount(stats.data['count.medium'])}</td>
            <td className="t">{l('100%')}</td>
          </tr>
          {formatStats.map((formatStat, i) => (
            <tr className={(i + 1) % 2 === 0 ? 'even' : 'odd'} key={formatStat.medium_stat}>
              <td className="t">{i + 1}</td>
              <td>{formatStat.entity ? <LinkSearchableProperty entityType="release" searchField="format" searchValue={formatStat.entity.name.replace('"', '\\"')} text={l(formatStat.entity.name)} /> : l('Unknown Format')}</td>
              <td className="t">{formatCount(formatStat.release_count)}</td>
              <td className="t">{formatPercentage(formatStat.release_count / stats.data['count.release'], 2)}</td>
              <td className="t">{formatCount(formatStat.medium_count)}</td>
              <td className="t">{formatPercentage(formatStat.medium_count / stats.data['count.medium'], 2)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </Layout>
  );
};

module.exports = Formats;
