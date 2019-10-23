/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import manifest from '../static/manifest';
import {l_statistics as l} from '../static/scripts/common/i18n/statistics';
import EntityLink from '../static/scripts/common/components/EntityLink';
import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';

import {formatCount} from './utilities';
import StatisticsLayout from './StatisticsLayout';

type CountriesStatsT = {
  +$c: CatalystContextT,
  +countryStats: $ReadOnlyArray<CountryStatT>,
  +dateCollected: string,
};

type CountryStatT = {
  +artist_count: number,
  +entity: AreaT,
  +label_count: number,
  +release_count: number,
};

const Countries = ({$c, countryStats, dateCollected}: CountriesStatsT) => (
  <StatisticsLayout fullWidth page="countries" title={l('Countries')}>
    <p>
      {texp.l('Last updated: {date}',
              {date: dateCollected})}
    </p>
    <table className="tbl" id="countries-table">
      <thead>
        <tr>
          <th className="pos">{l('Rank')}</th>
          <th>
            {l('Country')}
            <div className="arrow" />
          </th>
          <th>
            {l('Artists')}
            <div className="arrow" />
          </th>
          <th>
            {l('Releases')}
            <div className="arrow" />
          </th>
          <th>
            {l('Labels')}
            <div className="arrow" />
          </th>
          <th>
            {l('Total')}
            <div className="arrow" />
          </th>
        </tr>
      </thead>
      <tbody>
        {countryStats.map((countryStat, index) => {
          const country = countryStat.entity;
          const hasCountryCode = country && country.country_code;
          return (
            <tr
              className={loopParity(index)}
              key={
                country
                  ? country.gid
                  : `missing-${index}`
              }
            >
              <td className="t">{index + 1}</td>
              <td>
                {hasCountryCode
                  ? <EntityLink entity={country} />
                  : l('Unknown Country')}
              </td>
              <td className="t">
                {hasCountryCode ? (
                  <EntityLink
                    content={formatCount($c, countryStat.artist_count)}
                    entity={country}
                    subPath="artists"
                  />
                ) : formatCount($c, countryStat.artist_count)}
              </td>
              <td className="t">
                {hasCountryCode ? (
                  <EntityLink
                    content={
                      formatCount($c, countryStat.release_count)}
                    entity={country}
                    subPath="releases"
                  />
                ) : formatCount($c, countryStat.release_count)}
              </td>
              <td className="t">
                {hasCountryCode ? (
                  <EntityLink
                    content={formatCount($c, countryStat.label_count)}
                    entity={country}
                    subPath="labels"
                  />
                ) : formatCount($c, countryStat.label_count)}
              </td>
              <td className="t">
                {formatCount(
                  $c,
                  countryStat.artist_count +
                  countryStat.release_count +
                  countryStat.label_count,
                )}
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
    {manifest.js('statistics')}
  </StatisticsLayout>
);

export default withCatalystContext(Countries);
