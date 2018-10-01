9/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l_statistics, ln_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';
import manifest from '../static/manifest';

import {formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';
import type {CoverArtStatsT} from './types';

const nameOrNull = (name: string, defaultName: string) => {
  if (name === 'null') {
    return defaultName;
  } else {
    return l_statistics(name);
  }
};

const CoverArt = ({
  $c,
  dateCollected,
  releaseTypeStats,
  releaseStatusStats,
  releaseFormatStats,
  stats,
  typeStats,
}: CoverArtStatsT) => {
  const oneToTwentyNine = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
  return (
    <StatisticsLayout fullWidth page="coverart" title={l_statistics('Cover Art')}>
      {manifest.css('statistics')}
      <p>{l_statistics('Last updated: {date}',
        {__react: true, date: dateCollected})}
      </p>
      <h2>{l_statistics('Basics')}</h2>
      {/* TODO: check why this seems to just not exist rather than be 0 */}
      {stats.data['count.release.has_caa'] < 1 ? (
        <p>
          {l_statistics('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr>
              <th>{l_statistics('Releases with cover art:')}</th>
              <td>{formatCount(stats.data['count.release.has_caa'], $c)}</td>
              <td>{formatPercentage(stats.data['count.release.has_caa'] / stats.data['count.release'], 1, $c)}</td>
            </tr>
            <tr>
              <th>{l_statistics('Pieces of cover art:')}</th>
              <td>{formatCount(stats.data['count.coverart'], $c)}</td>
              <td />
            </tr>
          </tbody>
        </table>
      )}
      <h2>{l_statistics('Releases')}</h2>
      {releaseTypeStats.length === 0 && releaseStatusStats.length === 0 && releaseFormatStats.length === 0 ? (
        <p>
          {l_statistics('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l_statistics('By Release Group Type')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Releases with cover art:')}</th>
              <td>{formatCount(stats.data['count.release.has_caa'], $c)}</td>
              <td />
            </tr>
            {releaseTypeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>{nameOrNull(type.type, l_statistics('No type'))}</th>
                <td>{formatCount(stats.data[type.stat_name], $c)}</td>
                <td>{formatPercentage(type.stat_name / stats.data['count.release.has_caa'], 1, $c)}</td>
              </tr>
            ))}
            <tr className="thead">
              <th colSpan="4">{l_statistics('By Release Status')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Releases with cover art:')}</th>
              <td>{formatCount(stats.data['count.release.has_caa'], $c)}</td>
              <td />
            </tr>
            {releaseStatusStats.map((status, index) => (
              <tr key={'status' + index}>
                <th />
                <th>{nameOrNull(status.status, l_statistics('No status'))}</th>
                <td>{formatCount(stats.data[status.stat_name], $c)}</td>
                <td>{formatPercentage(status.stat_name / stats.data['count.release.has_caa'], 1, $c)}</td>
              </tr>
            ))}
            <tr className="thead">
              <th colSpan="4">{l_statistics('By Release Format')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Releases with cover art:')}</th>
              <td>{formatCount(stats.data['count.release.has_caa'], $c)}</td>
              <td />
            </tr>
            {releaseFormatStats.map((format, index) => (
              <tr key={'format' + index}>
                <th />
                <th>{nameOrNull(format.format, l_statistics('No format'))}</th>
                <td>{formatCount(stats.data[format.stat_name], $c)}</td>
                <td>{formatPercentage(format.stat_name / stats.data['count.release.has_caa'], 1, $c)}</td>
              </tr>
            ))}
          </tbody>
        </table>)
      }
      <h2>{l_statistics('Release groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr>
            <th colSpan="2">{l_statistics('Release groups with cover art:')}</th>
            <td>{formatCount(stats.data['count.releasegroup.caa'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('manually selected:')}</th>
            <td>{formatCount(stats.data['count.releasegroup.caa.manually_selected'], $c)}</td>
            <td>{formatPercentage(stats.data['count.releasegroup.caa.manually_selected'] / stats.data['count.releasegroup.caa'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('automatically inferred:')}</th>
            <td>{formatCount(stats.data['count.releasegroup.caa.inferred'], $c)}</td>
            <td>{formatPercentage(stats.data['count.releasegroup.caa.inferred'] / stats.data['count.releasegroup.caa'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Pieces of cover art')}</h2>
      {stats.data['count.release.has_caa'] < 1 ? (
        <p>
          {l_statistics('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l_statistics('By Cover Art Type')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Pieces of cover art:')}</th>
              <td>{formatCount(stats.data['count.coverart'], $c)}</td>
              <td />
            </tr>
            {typeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>{nameOrNull(type.type, l_statistics('No type'))}</th>
                <td>{formatCount(stats.data[type.stat_name], $c)}</td>
                <td>{formatPercentage(stats.data[type.stat_name] / stats.data['count.coverart'], 1, $c)}</td>
              </tr>
            ))}
            <tr className="thead">
              <th colSpan="4">{l_statistics('Per release')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Releases with cover art:')}</th>
              <td>{formatCount(stats.data['count.release.has_caa'], $c)}</td>
              <td />
            </tr>
            {oneToTwentyNine.map((number) => (
              <tr key={number}>
                <th />
                <th>{ln_statistics('with {num} piece of cover art:', 'with {num} pieces of cover art:', {__react: true, num: number})}
                </th>
                <td>{formatCount(stats.data['count.coverart.per_release.' + number + 'images'], $c)}</td>
                <td>{formatPercentage(stats.data['count.coverart.per_release.' + number + 'images'] / stats.data['count.release.has_caa'], 1, $c)}</td>
              </tr>
            ))}
            <tr>
              <th />
              <th>{l_statistics('with 30 or more pieces of cover art:')}</th>
              <td>{formatCount(stats.data['count.coverart.per_release.30images'], $c)}</td>
              <td>{formatPercentage(stats.data['count.coverart.per_release.30images'] / stats.data['count.release.has_caa'], 1, $c)}</td>
            </tr>
          </tbody>
        </table>
      )}
    </StatisticsLayout>
  );
};

export default withCatalystContext(CoverArt);
