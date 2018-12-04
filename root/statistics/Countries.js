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

import manifest from '../static/manifest';
import {l_statistics} from '../static/scripts/common/i18n/statistics';
import EntityLink from '../static/scripts/common/components/EntityLink';
import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';

import {formatCount} from './utilities';
import StatisticsLayout from './StatisticsLayout';

type CountriesStatsT = {|
  +$c: CatalystContextT,
  +countryStats: $ReadOnlyArray<CountryStatT>,
  +dateCollected: string,
|};

type CountryStatT = {|
  +artist_count: number,
  +entity: AreaT,
  +label_count: number,
  +release_count: number,
|};

const Countries = ({$c, countryStats, dateCollected}: CountriesStatsT) => (
  <StatisticsLayout fullWidth page="countries" title={l_statistics('Countries')}>
    {manifest.css('statistics')}
    <p>{l_statistics('Last updated: {date}',
      {__react: true, date: dateCollected})}
    </p>
    <table className="tbl">
      <thead>
        <tr>
          <th className="pos">{l_statistics('Rank')}</th>
          <th>{l_statistics('Country')}<div className="arrow" /></th>
          <th>{l_statistics('Artists')}<div className="arrow" /></th>
          <th>{l_statistics('Releases')}<div className="arrow" /></th>
          <th>{l_statistics('Labels')}<div className="arrow" /></th>
          <th>{l_statistics('Total')}<div className="arrow" /></th>
        </tr>
      </thead>
      <tbody>
        {countryStats.map((country, index) => (
          <tr className={loopParity(index)} key={country.entity.gid}>
            <td className="t">{index + 1}</td>
            <td>
              {country.entity.country_code
                ? <EntityLink entity={country.entity} />
                : l_statistics('Unknown Country')}
            </td>
            <td className="t">{country.entity.country_code ? <EntityLink content={formatCount(country.artist_count, $c)} entity={country.entity} subPath="artists" /> : formatCount(country.artist_count, $c)}</td>
            <td className="t">{country.entity.country_code ? <EntityLink content={formatCount(country.release_count, $c)} entity={country.entity} subPath="releases" /> : formatCount(country.release_count, $c)}</td>
            <td className="t">{country.entity.country_code ? <EntityLink content={formatCount(country.label_count, $c)} entity={country.entity} subPath="labels" /> : formatCount(country.label_count, $c)}</td>
            <td className="t">{formatCount(country.artist_count + country.release_count + country.label_count, $c)}</td>
          </tr>
        ))}
      </tbody>
    </table>
    {manifest.js('statistics')}
  </StatisticsLayout>
);

export default withCatalystContext(Countries);
