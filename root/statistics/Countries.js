/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {l as lMbServer} from '../static/scripts/common/i18n.js';
import loopParity from '../utility/loopParity.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, TimelineLink} from './utilities.js';

type CountryStatT = {
  +artist_count: number,
  +entity: AreaT,
  +event_count: number,
  +label_count: number,
  +place_count: number,
  +release_count: number,
};

component Countries(
  countryStats: $ReadOnlyArray<CountryStatT>,
  dateCollected: string,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout
      fullWidth
      page="countries"
      title={l_statistics('Countries')}
    >
      <p>
        {texp.l_statistics('Last updated: {date}',
                           {date: dateCollected})}
      </p>
      <table className="tbl" id="countries-table">
        <thead>
          <tr>
            <th className="pos">{l_statistics('Rank')}</th>
            <th>
              {lMbServer('Country')}
              <div className="arrow" />
            </th>
            <th>
              {lMbServer('Artists')}
              <div className="arrow" />
            </th>
            <th>
              {lMbServer('Releases')}
              <div className="arrow" />
            </th>
            <th>
              {lMbServer('Labels')}
              <div className="arrow" />
            </th>
            <th>
              {lMbServer('Events')}
              <div className="arrow" />
            </th>
            <th>
              {lMbServer('Places')}
              <div className="arrow" />
            </th>
            <th>
              {l_statistics('Total')}
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
                    : l_statistics('Unknown country')}
                </td>
                <td className="t">
                  {hasCountryCode ? (
                    <EntityLink
                      content={formatCount($c, countryStat.artist_count)}
                      entity={country}
                      subPath="artists"
                    />
                  ) : formatCount($c, countryStat.artist_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.artist.country.' + (hasCountryCode
                        ? country.country_code
                        : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {hasCountryCode ? (
                    <EntityLink
                      content={
                        formatCount($c, countryStat.release_count)
                      }
                      entity={country}
                      subPath="releases"
                    />
                  ) : formatCount($c, countryStat.release_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.release.country.' + (hasCountryCode
                        ? country.country_code
                        : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {hasCountryCode ? (
                    <EntityLink
                      content={formatCount($c, countryStat.label_count)}
                      entity={country}
                      subPath="labels"
                    />
                  ) : formatCount($c, countryStat.label_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.label.country.' + (hasCountryCode
                        ? country.country_code
                        : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {hasCountryCode ? (
                    <EntityLink
                      content={formatCount($c, countryStat.event_count)}
                      entity={country}
                      subPath="events"
                    />
                  ) : formatCount($c, countryStat.event_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.event.country.' + (hasCountryCode
                        ? country.country_code
                        : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {hasCountryCode ? (
                    <EntityLink
                      content={formatCount($c, countryStat.place_count)}
                      entity={country}
                      subPath="places"
                    />
                  ) : formatCount($c, countryStat.place_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.event.country.' + (hasCountryCode
                        ? country.country_code
                        : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {formatCount(
                    $c,
                    countryStat.artist_count +
                    countryStat.release_count +
                    countryStat.label_count +
                    countryStat.event_count +
                    countryStat.place_count,
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
      {manifest('statistics')}
    </StatisticsLayout>
  );
}

export default Countries;
