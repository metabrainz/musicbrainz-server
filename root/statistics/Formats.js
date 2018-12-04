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

import {lp_attributes} from '../static/scripts/common/i18n/attributes';
import {l_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';
import LinkSearchableProperty from '../components/LinkSearchableProperty';

import {formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';
import type {StatsT} from './types';

type FormatsStatsT = {|
  +$c: CatalystContextT,
  +dateCollected: string,
  +formatStats: $ReadOnlyArray<FormatStatT>,
  +stats: StatsT,
|};

type FormatStatT = {|
  +entity: MediumFormatT | null,
  +medium_count: number,
  +medium_stat: string,
  +release_count: number,
  +release_stat: string,
|};

const Formats = ({$c, dateCollected, formatStats, stats}: FormatsStatsT) => (
  <StatisticsLayout fullWidth page="formats" title={l_statistics('Release/Medium Formats')}>
    <p>{l_statistics('Last updated: {date}',
      {date: dateCollected})}
    </p>
    <h2>{l_statistics('Release/Medium Formats')}</h2>
    <table className="tbl">
      <thead>
        <tr>
          <th className="pos">{l_statistics('Rank')}</th>
          <th>{l_statistics('Format')}</th>
          <th>{l_statistics('Releases')}</th>
          <th>{l_statistics('% of total releases')}</th>
          <th>{l_statistics('Mediums')}</th>
          <th>{l_statistics('% of total mediums')}</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td />
          <td>{l_statistics('Total')}</td>
          <td className="t">{formatCount(stats.data['count.release'], $c)}</td>
          <td className="t">{l_statistics('100%')}</td>
          <td className="t">{formatCount(stats.data['count.medium'], $c)}</td>
          <td className="t">{l_statistics('100%')}</td>
        </tr>
        {formatStats.map((formatStat, index) => {
          const entity = formatStat.entity;
          return (
            <tr className={loopParity(index)} key={formatStat.medium_stat}>
              <td className="t">{index + 1}</td>
              <td>{entity ? <LinkSearchableProperty entityType="release" searchField="format" searchValue={entity.name.replace('"', '\\"')} text={lp_attributes(entity.name, 'medium_format')} /> : l_statistics('Unknown Format')}</td>
              <td className="t">{formatCount(formatStat.release_count, $c)}</td>
              <td className="t">{formatPercentage(formatStat.release_count / stats.data['count.release'], 2, $c)}</td>
              <td className="t">{formatCount(formatStat.medium_count, $c)}</td>
              <td className="t">{formatPercentage(formatStat.medium_count / stats.data['count.medium'], 2, $c)}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  </StatisticsLayout>
);

export default withCatalystContext(Formats);
