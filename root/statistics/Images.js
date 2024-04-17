/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import mapRange from '../static/scripts/common/utility/mapRange.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, formatPercentage, TimelineLink} from './utilities.js';

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

type EventArtEventTypeStatT = {
  +stat_name: string,
  +type: string,
};

type ArtTypeStatT = {
  +stat_name: string,
  +type: string,
};

const nameOrNull = (name: string, defaultName: string) => {
  if (name === 'null') {
    return defaultName;
  }

  return name;
};

component Images(
  coverArtTypeStats: $ReadOnlyArray<ArtTypeStatT>,
  dateCollected: string,
  eventArtTypeStats: $ReadOnlyArray<ArtTypeStatT>,
  eventTypeStats: $ReadOnlyArray<EventArtEventTypeStatT>,
  releaseFormatStats: $ReadOnlyArray<CoverArtReleaseFormatStatT>,
  releaseStatusStats: $ReadOnlyArray<CoverArtReleaseStatusStatT>,
  releaseTypeStats: $ReadOnlyArray<CoverArtReleaseTypeStatT>,
  stats: {[statName: string]: number},
) {
  const $c = React.useContext(CatalystContext);
  const noImageStatistics = (
    stats['count.release.has_caa'] < 1 &&
    stats['count.event.has_eaa'] < 1
  );
  return (
    <StatisticsLayout
      fullWidth
      page="images"
      title={l_statistics('Images')}
    >
      <p>
        {texp.l_statistics('Last updated: {date}', {date: dateCollected})}
      </p>
      <h2>{l_statistics('Basics')}</h2>
      {noImageStatistics ? (
        <p>
          {l_statistics('No image statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr>
              <th>{l_statistics('Releases with cover art:')}</th>
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
              <th>{l_statistics('Pieces of cover art:')}</th>
              <td>
                {formatCount($c, stats['count.coverart'])}
                {' '}
                <TimelineLink statName="count.coverart" />
              </td>
              <td />
            </tr>
            <tr>
              <th>{addColonText(l_statistics('Events with event art'))}</th>
              <td>
                {formatCount($c, stats['count.event.has_eaa'])}
                {' '}
                <TimelineLink statName="count.event.has_eaa" />
              </td>
              <td>
                {formatPercentage(
                  $c,
                  stats['count.event.has_eaa'] / stats['count.event'],
                  1,
                )}
              </td>
            </tr>
            <tr>
              <th>{addColonText(l_statistics('Pieces of event art'))}</th>
              <td>
                {formatCount($c, stats['count.eventart'])}
                {' '}
                <TimelineLink statName="count.eventart" />
              </td>
              <td />
            </tr>
          </tbody>
        </table>
      )}
      <h2>{l_statistics('Releases')}</h2>
      {(releaseTypeStats.length === 0 &&
        releaseStatusStats.length === 0 &&
        releaseFormatStats.length === 0) ? (
          <p>
            {l_statistics('No cover art statistics available.')}
          </p>
        ) : (
          <table className="database-statistics">
            <tbody>
              <tr className="thead">
                <th colSpan="4">{l_statistics('By release group type')}</th>
              </tr>
              <tr>
                <th colSpan="2">
                  {l_statistics('Releases with cover art:')}
                </th>
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
                      l_statistics('No type'),
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
                <th colSpan="4">{l_statistics('By release status')}</th>
              </tr>
              <tr>
                <th colSpan="2">
                  {l_statistics('Releases with cover art:')}
                </th>
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
                      l_statistics('No status'),
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
                <th colSpan="4">{l_statistics('By release format')}</th>
              </tr>
              <tr>
                <th colSpan="2">
                  {l_statistics('Releases with cover art:')}
                </th>
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
                      l_statistics('No format'),
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
          </table>)}
      <h2>{l_statistics('Release groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr>
            <th colSpan="2">
              {l_statistics('Release groups with cover art:')}
            </th>
            <td>
              {formatCount($c, stats['count.releasegroup.caa'])}
              {' '}
              <TimelineLink statName="count.releasegroup.caa" />
            </td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('manually selected:')}</th>
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
            <th>{l_statistics('automatically inferred:')}</th>
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

      <h2>{l_statistics('Pieces of cover art')}</h2>
      {stats['count.release.has_caa'] < 1 ? (
        <p>
          {l_statistics('No cover art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l_statistics('By cover art type')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Pieces of cover art:')}</th>
              <td>
                {formatCount($c, stats['count.coverart'])}
                {' '}
                <TimelineLink statName="count.coverart" />
              </td>
              <td />
            </tr>
            {coverArtTypeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>
                  {nameOrNull(
                    lp_attributes(type.type, 'cover_art_type'),
                    l_statistics('No type'),
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
              <th colSpan="4">{l_statistics('Per release')}</th>
            </tr>
            <tr>
              <th colSpan="2">{l_statistics('Releases with cover art:')}</th>
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
                  {texp.ln_statistics(
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
              <th>{l_statistics('with 30 or more pieces of cover art:')}</th>
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

      <h2>{l_statistics('Events')}</h2>
      {eventTypeStats.length === 0 ? (
        <p>
          {l_statistics('No event art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l_statistics('By event type')}</th>
            </tr>
            <tr>
              <th colSpan="2">
                {addColonText(l_statistics('Events with event art'))}
              </th>
              <td>
                {formatCount($c, stats['count.event.has_eaa'])}
                {' '}
                <TimelineLink statName="count.event.has_eaa" />
              </td>
              <td />
            </tr>
            {eventTypeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>
                  {nameOrNull(
                    lp_attributes(type.type, 'event_type'),
                    l_statistics('No type'),
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
                    stats[type.stat_name] / stats['count.event.has_eaa'],
                    1,
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <h2>{l_statistics('Pieces of event art')}</h2>
      {stats['count.event.has_eaa'] < 1 ? (
        <p>
          {l_statistics('No event art statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr className="thead">
              <th colSpan="4">{l_statistics('By event art type')}</th>
            </tr>
            <tr>
              <th colSpan="2">
                {addColonText(l_statistics('Pieces of event art'))}
              </th>
              <td>
                {formatCount($c, stats['count.eventart'])}
                {' '}
                <TimelineLink statName="count.eventart" />
              </td>
              <td />
            </tr>
            {eventArtTypeStats.map((type, index) => (
              <tr key={'type' + index}>
                <th />
                <th>
                  {nameOrNull(
                    lp_attributes(type.type, 'event_art_type'),
                    l_statistics('No type'),
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
                    stats[type.stat_name] / stats['count.eventart'],
                    1,
                  )}
                </td>
              </tr>
            ))}
            <tr className="thead">
              <th colSpan="4">{l_statistics('Per event')}</th>
            </tr>
            <tr>
              <th colSpan="2">
                {addColonText(l_statistics('Events with event art'))}
              </th>
              <td>
                {formatCount($c, stats['count.event.has_eaa'])}
                {' '}
                <TimelineLink statName="count.event.has_eaa" />
              </td>
              <td />
            </tr>
            {mapRange(1, 14, (number) => (
              <tr key={number}>
                <th />
                <th>
                  {texp.ln_statistics(
                    'with {num} piece of event art:',
                    'with {num} pieces of event art:',
                    number,
                    {num: number},
                  )}
                </th>
                <td>
                  {formatCount(
                    $c,
                    stats['count.eventart.per_event.' + number + 'images'],
                  )}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.eventart.per_event.' + number + 'images'
                    }
                  />
                </td>
                <td>
                  {formatPercentage(
                    $c,
                    stats['count.eventart.per_event.' + number + 'images'] /
                      stats['count.event.has_eaa'],
                    1,
                  )}
                </td>
              </tr>
            ))}
            <tr>
              <th />
              <th>{l_statistics('with 15 or more pieces of event art:')}</th>
              <td>
                {formatCount(
                  $c,
                  stats['count.eventart.per_event.15images'],
                )}
                {' '}
                <TimelineLink
                  statName="count.eventart.per_event.15images"
                />
              </td>
              <td>
                {formatPercentage(
                  $c,
                  stats['count.eventart.per_event.15images'] /
                    stats['count.event.has_eaa'],
                  1,
                )}
              </td>
            </tr>
          </tbody>
        </table>
      )}
    </StatisticsLayout>
  );
}

export default Images;
