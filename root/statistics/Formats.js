/*
 * @flow strict-local
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {l_statistics as l} from '../static/scripts/common/i18n/statistics.js';
import loopParity from '../utility/loopParity.js';
import LinkSearchableProperty from '../components/LinkSearchableProperty.js';

import {formatCount, formatPercentage, TimelineLink} from './utilities.js';
import StatisticsLayout from './StatisticsLayout.js';

type FormatsStatsT = {
  +dateCollected: string,
  +formatStats: $ReadOnlyArray<FormatStatT>,
  +stats: {[statName: string]: number},
};

type FormatStatT = {
  +entity: MediumFormatT | null,
  +medium_count: number,
  +medium_stat: string,
  +release_count: number,
  +release_stat: string,
};

const Formats = ({
  dateCollected,
  formatStats,
  stats,
}: FormatsStatsT): React.Element<typeof StatisticsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout
      fullWidth
      page="formats"
      title={l('Release/Medium Formats')}
    >
      <p>
        {texp.l('Last updated: {date}',
                {date: dateCollected})}
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
            <td className="t">
              {formatCount($c, stats['count.release'])}
              {' '}
              <TimelineLink statName="count.release" />
            </td>
            <td className="t">{formatPercentage($c, 1, 0)}</td>
            <td className="t">
              {formatCount($c, stats['count.medium'])}
              {' '}
              <TimelineLink statName="count.medium" />
            </td>
            <td className="t">{formatPercentage($c, 1, 0)}</td>
          </tr>
          {formatStats.map((formatStat, index) => {
            const entity = formatStat.entity;
            return (
              <tr className={loopParity(index)} key={formatStat.medium_stat}>
                <td className="t">{index + 1}</td>
                <td>
                  {entity
                    ? (
                      <LinkSearchableProperty
                        entityType="release"
                        searchField="format"
                        searchValue={entity.name}
                        text={lp_attributes(entity.name, 'medium_format')}
                      />
                    ) : l('Unknown Format')}
                </td>
                <td className="t">
                  {formatCount($c, formatStat.release_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.release.format.' + (entity ? entity.id : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {formatPercentage(
                    $c,
                    formatStat.release_count / stats['count.release'],
                    2,
                  )}
                </td>
                <td className="t">
                  {formatCount($c, formatStat.medium_count)}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.medium.format.' + (entity ? entity.id : 'null')
                    }
                  />
                </td>
                <td className="t">
                  {formatPercentage(
                    $c,
                    formatStat.medium_count / stats['count.medium'],
                    2,
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </StatisticsLayout>
  );
};

export default Formats;
