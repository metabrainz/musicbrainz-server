/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {l_statistics as l}
  from '../static/scripts/common/i18n/statistics.js';
import mapRange from '../static/scripts/common/utility/mapRange.js';

import {formatCount, formatPercentage, TimelineLink} from './utilities.js';
import StatisticsLayout from './StatisticsLayout.js';

type CoverArtStatsT = {
  +dateCollected: string,
  +releaseFormatStats: $ReadOnlyArray<CoverArtReleaseFormatStatT>,
  +releaseStatusStats: $ReadOnlyArray<CoverArtReleaseStatusStatT>,
  +releaseTypeStats: $ReadOnlyArray<CoverArtReleaseTypeStatT>,
  +stats: {[statName: string]: number},
  +typeStats: $ReadOnlyArray<CoverArtTypeStatT>,
};

type CoverArtReleaseFormatStatT = {
  +format: string,
  +stat_name: string,
};

type CoverArtReleaseStatusStatT = {
  +stat_name: string,
  +status: string,
};

type CoverArtReleaseTypeStatT = {
  +stat_name: string,
  +type: string,
};

type CoverArtTypeStatT = {
  +stat_name: string,
  +type: string,
};

const nameOrNull = (name: string, defaultName: string) => {
  if (name === 'null') {
    return defaultName;
  }

  return name;
};

const CoverArt = ({
  dateCollected,
  releaseTypeStats,
  releaseStatusStats,
  releaseFormatStats,
  stats,
  typeStats,
}: CoverArtStatsT): React.Element<typeof StatisticsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout fullWidth page="coverart" title={l('Cover Art')}>
      <p>
        {texp.l('Last updated: {date}', {date: dateCollected})}
      </p>
      <h2>{l('Basics')}</h2>
      {stats['count.release.has_caa'] < 1 ? (
        <p>
          {l('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr>
              <th>{l('Releases with cover art:')}</th>
              <td>
                {formatCount($c, stats['count.release.has_caa'])}
                {' '}
                <TimelineLink statName="count.release.has_caa" />
              </td>
              <td>
                {formatPercentage(
                  $c,
                  stats['count.release.has_caa'] / stats['count.release'],
                  1,
                )}
              </td>
            </tr>
            <tr>
              <th>{l('Pieces of cover art:')}</th>
              <td>
                {formatCount($c, stats['count.coverart'])}
                {' '}
                <TimelineLink statName="count.coverart" />
              </td>
              <td />
            </tr>
          </tbody>
        </table>
      )}
      <h2>{l('Releases')}</h2>
      {(releaseTypeStats.length === 0 &&
        releaseStatusStats.length === 0 &&
        releaseFormatStats.length === 0) ? (
          <p>
            {l('No cover art statistics available.')}
          </p>
        ) : (
          <table className="database-statistics">
            <tbody>
              <tr className="thead">
                <th colSpan="4">{l('By Release Group Type')}</th>
              </tr>
              <tr>
                <th colSpan="2">{l('Releases with cover art:')}</th>
                <td>
                  {formatCount($c, stats['count.release.has_caa'])}
                  {' '}
                  <TimelineLink statName="count.release.has_caa" />
                </td>
                <td />
              </tr>
              {releaseTypeStats.map((type, index) => (
                <tr key={'type' + index}>
                  <th />
                  <th>
                    {nameOrNull(
                      lp_attributes(type.type, 'release_group_primary_type'),
                      l('No type'),
                    )}
                  </th>
                  <td>
                    {formatCount($c, stats[type.stat_name])}
                    {' '}
                    <TimelineLink statName={type.stat_name} />
                  </td>
                  <td>
                    {formatPercentage(
                      $c,
                      stats[type.stat_name] / stats['count.release.has_caa'],
                      1,
                    )}
                  </td>
                </tr>
              ))}
              <tr className="thead">
                <th colSpan="4">{l('By Release Status')}</th>
              </tr>
              <tr>
                <th colSpan="2">{l('Releases with cover art:')}</th>
                <td>
                  {formatCount($c, stats['count.release.has_caa'])}
                  {' '}
                  <TimelineLink statName="count.release.has_caa" />
                </td>
                <td />
              </tr>
              {releaseStatusStats.map((status, index) => (
                <tr key={'status' + index}>
                  <th />
                  <th>
                    {nameOrNull(
                      lp_attributes(status.status, 'release_status'),
                      l('No status'),
                    )}
                  </th>
                  <td>
                    {formatCount($c, stats[status.stat_name])}
                    {' '}
                    <TimelineLink statName={status.stat_name} />
                  </td>
                  <td>
                    {formatPercentage(
                      $c,
                      stats[status.stat_name] /
                        stats['count.release.has_caa'],
                      1,
                    )}
                  </td>
                </tr>
              ))}
              <tr className="thead">
                <th colSpan="4">{l('By Release Format')}</th>
              </tr>
              <tr>
                <th colSpan="2">{l('Releases with cover art:')}</th>
                <td>
                  {formatCount($c, stats['count.release.has_caa'])}
                  {' '}
                  <TimelineLink statName="count.release.has_caa" />
                </td>
                <td />
              </tr>
              {releaseFormatStats.map((format, index) => (
                <tr key={'format' + index}>
                  <th />
                  <th>
                    {nameOrNull(
                      lp_attributes(format.format, 'medium_format'),
                      l('No format'),
                    )}
                  </th>
                  <td>
                    {formatCount($c, stats[format.stat_name])}
                    {' '}
                    <TimelineLink statName={format.stat_name} />
                  </td>
                  <td>
                    {formatPercentage(
                      $c,
                      stats[format.stat_name] /
                        stats['count.release.has_caa'],
                      1,
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>)
      }
      <h2>{l('Release groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr>
            <th colSpan="2">{l('Release groups with cover art:')}</th>
            <td>
              {formatCount($c, stats['count.releasegroup.caa'])}
              {' '}
              <TimelineLink statName="count.releasegroup.caa" />
            </td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('manually selected:')}</th>
            <td>
              {formatCount(
                $c,
                stats['count.releasegroup.caa.manually_selected'],
              )}
              {' '}
              <TimelineLink
                statName="count.releasegroup.caa.manually_selected"
              />
            </td>
            <td>
              {formatPercentage(
                $c,
                stats['count.releasegroup.caa.manually_selected'] /
                  stats['count.releasegroup.caa'],
                1,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l('automatically inferred:')}</th>
            <td>
              {formatCount($c, stats['count.releasegroup.caa.inferred'])}
              {' '}
              <TimelineLink statName="count.releasegroup.caa.inferred" />
            </td>
            <td>
              {formatPercentage(
                $c,
                stats['count.releasegroup.caa.inferred'] /
                  stats['count.releasegroup.caa'],
                1,
              )}
            </td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Pieces of cover art')}</h2>
      {stats['count.release.has_caa'] < 1 ? (
        <p>
          {l('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l('By Cover Art Type')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l('Pieces of cover art:')}</th>
              <td>
                {formatCount($c, stats['count.coverart'])}
                {' '}
                <TimelineLink statName="count.coverart" />
              </td>
              <td />
            </tr>
            {typeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>
                  {nameOrNull(
                    lp_attributes(type.type, 'cover_art_type'),
                    l('No type'),
                  )}
                </th>
                <td>
                  {formatCount($c, stats[type.stat_name])}
                  {' '}
                  <TimelineLink statName={type.stat_name} />
                </td>
                <td>
                  {formatPercentage(
                    $c,
                    stats[type.stat_name] / stats['count.coverart'],
                    1,
                  )}
                </td>
              </tr>
            ))}
            <tr className="thead">
              <th colSpan="4">{l('Per release')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l('Releases with cover art:')}</th>
              <td>
                {formatCount($c, stats['count.release.has_caa'])}
                {' '}
                <TimelineLink statName="count.release.has_caa" />
              </td>
              <td />
            </tr>
            {mapRange(1, 29, (number) => (
              <tr key={number}>
                <th />
                <th>
                  {texp.ln(
                    'with {num} piece of cover art:',
                    'with {num} pieces of cover art:',
                    number,
                    {num: number},
                  )}
                </th>
                <td>
                  {formatCount(
                    $c,
                    stats['count.coverart.per_release.' + number + 'images'],
                  )}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.coverart.per_release.' + number + 'images'
                    }
                  />
                </td>
                <td>
                  {formatPercentage(
                    $c,
                    stats['count.coverart.per_release.' + number + 'images'] /
                      stats['count.release.has_caa'],
                    1,
                  )}
                </td>
              </tr>
            ))}
            <tr>
              <th />
              <th>{l('with 30 or more pieces of cover art:')}</th>
              <td>
                {formatCount(
                  $c,
                  stats['count.coverart.per_release.30images'],
                )}
                {' '}
                <TimelineLink
                  statName="count.coverart.per_release.30images"
                />
              </td>
              <td>
                {formatPercentage(
                  $c,
                  stats['count.coverart.per_release.30images'] /
                    stats['count.release.has_caa'],
                  1,
                )}
              </td>
            </tr>
          </tbody>
        </table>
      )}
    </StatisticsLayout>
  );
};

export default CoverArt;
