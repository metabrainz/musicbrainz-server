/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LinkSearchableProperty from '../components/LinkSearchableProperty.js';
import {CatalystContext} from '../context.mjs';
import loopParity from '../utility/loopParity.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, formatPercentage, TimelineLink} from './utilities.js';

type FormatStatT = {
  +entity: MediumFormatT | null,
  +medium_count: number,
  +medium_stat: string,
  +release_count: number,
  +release_stat: string,
};

component Formats(
  dateCollected: string,
  formatStats: $ReadOnlyArray<FormatStatT>,
  stats: {[statName: string]: number},
) {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout
      fullWidth
      page="formats"
      title={l_statistics('Release/Medium Formats')}
    >
      <p>
        {texp.l_statistics('Last updated: {date}',
                           {date: dateCollected})}
      </p>
      <h2>{l_statistics('Release/Medium Formats')}</h2>
      <table className="tbl">
        <thead>
          <tr>
            <th className="pos">{l_statistics('Rank')}</th>
            <th>{l_mb_server('Format')}</th>
            <th>{l_mb_server('Releases')}</th>
            <th>{l_statistics('% of total releases')}</th>
            <th>{l_mb_server('Mediums')}</th>
            <th>{l_statistics('% of total mediums')}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td />
            <td>{l_statistics('Total')}</td>
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
                    ) : l_statistics('Unknown format')}
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
}

export default Formats;
