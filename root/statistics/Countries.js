/*
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const manifest = require('../static/manifest');
const {formatCount} = require('./utilities');
const {l} = require('../static/scripts/common/i18n');
const Layout = require('./Layout');
const EntityLink = require('../static/scripts/common/components/EntityLink');

const Countries = () => (
  <Layout fullWidth page="countries" title={l('Countries')}>
    {manifest.css('statistics')}
    <p>{l('Last updated: {date}',
      {__react: true, date: $c.stash.date_collected})}
    </p>
    <table className="tbl">
      <thead>
        <tr>
          <th className="pos">{l('Rank')}</th>
          <th>{l('Country')}<div className="arrow" /></th>
          <th>{l('Artists')}<div className="arrow" /></th>
          <th>{l('Releases')}<div className="arrow" /></th>
          <th>{l('Labels')}<div className="arrow" /></th>
          <th>{l('Total')}<div className="arrow" /></th>
        </tr>
      </thead>
      <tbody>
        {$c.stash.stats.map((country, i) => (
          <tr className={(i + 1) % 2 === 0 ? 'even' : 'odd'} key={country.entity.gid}>
            <td className="t">{i + 1}</td>
            <td>
              {country.entity.code
                ? <EntityLink entity={country.entity} />
                : l('Unknown Country')}
            </td>
            <td className="t"><EntityLink content={formatCount(country.artist_count)} entity={country.entity} subPath="artists" /></td>
            <td className="t"><EntityLink content={formatCount(country.release_count)} entity={country.entity} subPath="releases" /></td>
            <td className="t"><EntityLink content={formatCount(country.label_count)} entity={country.entity} subPath="labels" /></td>
            <td className="t">{formatCount(country.artist_count + country.release_count + country.label_count)}</td>
          </tr>
        ))}
      </tbody>
    </table>
    {manifest.js('statistics')}
  </Layout>
);

module.exports = Countries;
