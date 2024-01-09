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

import {CatalystContext} from '../context.mjs';
import {
  l_statistics,
  lp_statistics,
} from '../static/scripts/common/i18n/statistics.js';
import mapRange from '../static/scripts/common/utility/mapRange.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, formatPercentage, TimelineLink} from './utilities.js';

type MainStatsT = {
  +areaTypes: $ReadOnlyArray<AreaTypeT>,
  +dateCollected: string,
  +eventTypes: $ReadOnlyArray<EventTypeT>,
  +instrumentTypes: $ReadOnlyArray<InstrumentTypeT>,
  +labelTypes: $ReadOnlyArray<LabelTypeT>,
  +packagings: $ReadOnlyArray<ReleasePackagingT>,
  +placeTypes: $ReadOnlyArray<PlaceTypeT>,
  +primaryTypes: $ReadOnlyArray<ReleaseGroupTypeT>,
  +secondaryTypes: $ReadOnlyArray<ReleaseGroupSecondaryTypeT>,
  +seriesTypes: $ReadOnlyArray<SeriesTypeT>,
  +stats: {[statName: string]: number},
  +statuses: $ReadOnlyArray<ReleaseStatusT>,
  +workAttributeTypes: $ReadOnlyArray<WorkAttributeTypeT>,
  +workTypes: $ReadOnlyArray<WorkTypeT>,
};

const Index = ({
  areaTypes,
  dateCollected,
  eventTypes,
  instrumentTypes,
  labelTypes,
  packagings,
  placeTypes,
  primaryTypes,
  secondaryTypes,
  seriesTypes,
  stats,
  statuses,
  workAttributeTypes,
  workTypes,
}: MainStatsT): React$Element<typeof StatisticsLayout> => {
  const $c = React.useContext(CatalystContext);

  const nonGroupCount = stats['count.artist.type.null'] +
    stats['count.artist.type.person'] +
    stats['count.artist.type.character'] +
    stats['count.artist.type.other'];

  // formatCount shortcut (with timeline link)
  const fc = (a: string) => (
    <>
      {formatCount($c, stats['count.' + a])}
      {' '}
      <TimelineLink statName={'count.' + a} />
    </>
  );

  // formatPercentage shortcut
  const fp = (a: string, b: string) => (
    formatPercentage($c, stats['count.' + a] / stats['count.' + b], 1)
  );

  /*
   * Long-form for cases where `a` or `b` aren't keys in `stats`,
   * but so `$c` and `digits` still don't need to be provided.
   */
  const _formatPercentage =
    (a: number, b: number) => formatPercentage($c, a / b, 1);

  return (
    <StatisticsLayout fullWidth page="index" title={l_statistics('Overview')}>
      <p>
        {texp.l_statistics('Last updated: {date}', {date: dateCollected})}
      </p>
      <h2>{l_statistics('Basic metadata')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Core entities')}</th>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Artists'))}</th>
            <td colSpan="3">{fc('artist')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Release groups'))}</th>
            <td colSpan="3">{fc('releasegroup')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Releases'))}</th>
            <td colSpan="3">{fc('release')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Mediums'))}</th>
            <td colSpan="3">{fc('medium')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Recordings'))}</th>
            <td colSpan="3">{fc('recording')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Tracks'))}</th>
            <td colSpan="3">{fc('track')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Labels'))}</th>
            <td colSpan="3">{fc('label')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Works'))}</th>
            <td colSpan="3">{fc('work')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('URLs'))}</th>
            <td colSpan="3">{fc('url')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Areas'))}</th>
            <td colSpan="3">{fc('area')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Places'))}</th>
            <td colSpan="3">{fc('place')}</td>
          </tr>
          <tr>
            <th>{addColonText(lp_statistics('Series', 'plural'))}</th>
            <td colSpan="3">{fc('series')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Instruments'))}</th>
            <td colSpan="3">{fc('instrument')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Events'))}</th>
            <td colSpan="3">{fc('event')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Genres'))}</th>
            <td colSpan="3">{fc('genre')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Other entities')}</th>
          </tr>
          <tr>
            <th>{l_statistics('Editors (valid / deleted):')}</th>
            <td>{fc('editor.valid')}</td>
            <td>{'/'}</td>
            <td>{fc('editor.deleted')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Relationships'))}</th>
            <td colSpan="3">{fc('ar.links')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Collections'))}</th>
            <td colSpan="3">{fc('collection')}</td>
          </tr>
          <tr>
            <th>{l_statistics('CD stubs (all time / current):')}</th>
            <td>{fc('cdstub.submitted')}</td>
            <td>{'/'}</td>
            <td>
              {' '}
              {fc('cdstub')}
            </td>
          </tr>
          <tr>
            <th>{lp_statistics('Tags (raw / aggregated):', 'folksonomy')}</th>
            <td>{fc('tag.raw')}</td>
            <td>{'/'}</td>
            <td>{fc('tag')}</td>
          </tr>
          <tr>
            <th>{l_statistics('Ratings (raw / aggregated):')}</th>
            <td>{fc('rating.raw')}</td>
            <td>{'/'}</td>
            <td>{fc('rating')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Identifiers')}</th>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('MBIDs'))}</th>
            <td colSpan="3">{fc('mbid')}</td>
          </tr>
          <tr>
            <th>{l_statistics('ISRCs (all / unique):')}</th>
            <td>{fc('isrc.all')}</td>
            <td>{'/'}</td>
            <td>{fc('isrc')}</td>
          </tr>
          <tr>
            <th>{l_statistics('ISWCs (all / unique):')}</th>
            <td>{fc('iswc.all')}</td>
            <td>{'/'}</td>
            <td>{fc('iswc')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Disc IDs'))}</th>
            <td colSpan="3">{fc('discid')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Barcodes'))}</th>
            <td colSpan="3">{fc('barcode')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('IPIs'))}</th>
            <td colSpan="3">{fc('ipi')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('ISNIs'))}</th>
            <td colSpan="3">{fc('isni')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Artists')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Artists')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Artists'))}</th>
            <td>{fc('artist')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Person:')}</th>
            <td>{fc('artist.type.person')}</td>
            <td>{fp('artist.type.person', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Group:')}</th>
            <td>{fc('artist.type.group')}</td>
            <td>{fp('artist.type.group', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Orchestra:')}</th>
            <td>{fc('artist.type.orchestra')}</td>
            <td>{fp('artist.type.orchestra', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Choir:')}</th>
            <td>{fc('artist.type.choir')}</td>
            <td>{fp('artist.type.choir', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Character:')}</th>
            <td>{fc('artist.type.character')}</td>
            <td>{fp('artist.type.character', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Other:')}</th>
            <td>{fc('artist.type.other')}</td>
            <td>{fp('artist.type.other', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no type set:')}</th>
            <td>{fc('artist.type.null')}</td>
            <td>{fp('artist.type.null', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with appearances in artist credits:')}</th>
            <td>{fc('artist.has_credits')}</td>
            <td>{fp('artist.has_credits', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no appearances in artist credits:')}</th>
            <td>{fc('artist.0credits')}</td>
            <td>{fp('artist.0credits', 'artist')}</td>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Non-group artists:')}</th>
            <td>{formatCount($c, nonGroupCount)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Male:')}</th>
            <td>{fc('artist.gender.male')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.male'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Female:')}</th>
            <td>{fc('artist.gender.female')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.female'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{addColonText(l_statistics('Non-binary'))}</th>
            <td>{fc('artist.gender.nonbinary')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.nonbinary'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Other gender:')}</th>
            <td>{fc('artist.gender.other')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.other'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Gender not applicable:')}</th>
            <td>{fc('artist.gender.not_applicable')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.not_applicable'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no gender set:')}</th>
            <td>{fc('artist.gender.null')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.null'],
                nonGroupCount,
              )}
            </td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Releases, Data Quality, and Disc IDs')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Releases')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('by various artists:')}</th>
            <td>{fc('release.various')}</td>
            <td>{fp('release.various', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('by a single artist:')}</th>
            <td>{fc('release.nonvarious')}</td>
            <td>{fp('release.nonvarious', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Release status')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          {statuses.map(status => (
            <tr key={status.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(status.name, 'release_status')}
              </th>
              <td>{fc('release.status.' + status.id)}</td>
              <td>{fp('release.status.' + status.id, 'release')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No status set')}</th>
            <td>{fc('release.status.null')}</td>
            <td>{fp('release.status.null', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Release packaging')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          {packagings.map(packaging => (
            <tr key={packaging.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(packaging.name, 'release_packaging')}
              </th>
              <td>{fc('release.packaging.' + packaging.id)}</td>
              <td>{fp('release.packaging.' + packaging.id, 'release')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No packaging set')}</th>
            <td>{fc('release.packaging.null')}</td>
            <td>{fp('release.packaging.null', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Cover art sources')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('CAA:')}</th>
            <td>{fc('release.coverart.caa')}</td>
            <td>{fp('release.coverart.caa', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No front cover art:')}</th>
            <td>{fc('release.coverart.none')}</td>
            <td>{fp('release.coverart.none', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Data quality')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('High data quality'))}
            </th>
            <td>{fc('quality.release.high')}</td>
            <td>{fp('quality.release.high', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('Default data quality'))}
            </th>
            <td>{fc('quality.release.default')}</td>
            <td>{fp('quality.release.default', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Normal data quality'))}</th>
            <td>{fc('quality.release.normal')}</td>
            <td>{fp('quality.release.normal', 'quality.release.default')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Unknown data quality'))}</th>
            <td>{fc('quality.release.unknown')}</td>
            <td>
              {fp('quality.release.unknown', 'quality.release.default')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('Low data quality'))}
            </th>
            <td>{fc('quality.release.low')}</td>
            <td>{fp('quality.release.low', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Disc IDs')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Disc IDs'))}</th>
            <td>{fc('discid')}</td>
            <td />
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Releases'))}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Releases with no disc IDs:')}</th>
            <td>{fc('release.0discids')}</td>
            <td>{fp('release.0discids', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l_statistics('Releases with at least one disc ID:')}
            </th>
            <td>{fc('release.has_discid')}</td>
            <td>{fp('release.has_discid', 'release')}</td>
          </tr>
          {mapRange(1, 9, (num) => (
            <tr key={num}>
              <th />
              <th />
              <th>
                {texp.ln_statistics(
                  'with {num} disc ID:',
                  'with {num} disc IDs:',
                  num,
                  {num: num},
                )}
              </th>
              <td>{fc('release.' + num + 'discids')}</td>
              <td>
                {fp('release.' + num + 'discids', 'release.has_discid')}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l_statistics('with 10 or more disc IDs:')}</th>
            <td>{fc('release.10discids')}</td>
            <td>{fp('release.10discids', 'release.has_discid')}</td>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Mediums'))}</th>
            <td>{fc('medium')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Mediums with no disc IDs:')}</th>
            <td>{fc('medium.0discids')}</td>
            <td>{fp('medium.0discids', 'medium')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l_statistics('Mediums with at least one disc ID:')}
            </th>
            <td>{fc('medium.has_discid')}</td>
            <td>{fp('medium.has_discid', 'medium')}</td>
          </tr>
          {mapRange(1, 9, (num) => (
            <tr key={num}>
              <th />
              <th />
              <th>
                {texp.ln_statistics(
                  'with {num} disc ID:',
                  'with {num} disc IDs:',
                  num,
                  {num: num},
                )}
              </th>
              <td>{fc('medium.' + num + 'discids')}</td>
              <td>{fp('medium.' + num + 'discids', 'medium.has_discid')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l_statistics('with 10 or more disc IDs:')}</th>
            <td>{fc('medium.10discids')}</td>
            <td>{fp('medium.10discids', 'medium.has_discid')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Release groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Primary types')}</th>
          </tr>
          <tr>
            <th colSpan="2">
              {addColonText(l_statistics('Release groups'))}
            </th>
            <td>{fc('releasegroup')}</td>
            <td />
          </tr>
          {primaryTypes.map(primaryType => (
            <tr key={primaryType.gid}>
              <th />
              <th>
                {lp_attributes(
                  primaryType.name,
                  'release_group_primary_type',
                )}
              </th>
              <td>{fc('releasegroup.primary_type.' + primaryType.id)}</td>
              <td>
                {fp(
                  'releasegroup.primary_type.' + primaryType.id,
                  'releasegroup',
                )}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('releasegroup.primary_type.null')}</td>
            <td>{fp('releasegroup.primary_type.null', 'releasegroup')}</td>
          </tr>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Secondary types')}</th>
          </tr>
          <tr>
            <th colSpan="2">
              {addColonText(l_statistics('Release groups'))}
            </th>
            <td>{fc('releasegroup')}</td>
            <td />
          </tr>
          {secondaryTypes.map(secondaryType => (
            <tr key={secondaryType.gid}>
              <th />
              <th>
                {lp_attributes(
                  secondaryType.name,
                  'release_group_secondary_type',
                )}
              </th>
              <td>{fc('releasegroup.secondary_type.' + secondaryType.id)}</td>
              <td>
                {fp(
                  'releasegroup.secondary_type.' + secondaryType.id,
                  'releasegroup',
                )}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('releasegroup.secondary_type.null')}</td>
            <td>{fp('releasegroup.secondary_type.null', 'releasegroup')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Recordings')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="3">{l_statistics('Recordings')}</th>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Recordings'))}</th>
            <td>{fc('recording')}</td>
            <td />
          </tr>
          <tr>
            <th>{addColonText(l_statistics('Videos'))}</th>
            <td>{fc('video')}</td>
            <td>{fp('video', 'recording')}</td>
          </tr>
          <tr>
            <th>{addColonText(lp_statistics('Standalone', 'recording'))}</th>
            <td>{fc('recording.standalone')}</td>
            <td>{fp('recording.standalone', 'recording')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('With ISRCs'))}</th>
            <td>{fc('recording.has_isrc')}</td>
            <td>{fp('recording.has_isrc', 'recording')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Labels')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Labels'))}</th>
            <td>{fc('label')}</td>
            <td />
          </tr>
          {labelTypes.map(labelType => (
            <tr key={labelType.gid}>
              <th />
              <th>{lp_attributes(labelType.name, 'label_type')}</th>
              <td>{fc('label.type.' + labelType.id)}</td>
              <td>{fp('label.type.' + labelType.id, 'label')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('label.type.null')}</td>
            <td>{fp('label.type.null', 'label')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Works')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Works'))}</th>
            <td>{fc('work')}</td>
            <td />
          </tr>
          {workTypes.map(workType => (
            <tr key={workType.gid}>
              <th />
              <th>{lp_attributes(workType.name, 'work_type')}</th>
              <td>{fc('work.type.' + workType.id)}</td>
              <td>{fp('work.type.' + workType.id, 'work')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('work.type.null')}</td>
            <td>{fp('work.type.null', 'work')}</td>
          </tr>
          <tr>
            <th>{addColonText(l_statistics('With ISWCs'))}</th>
            <td>{fc('work.has_iswc')}</td>
            <td>{fp('work.has_iswc', 'work')}</td>
          </tr>
        </tbody>
      </table>

      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Attributes')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Works'))}</th>
            <td>{fc('work')}</td>
            <td />
          </tr>
          {workAttributeTypes.map(workAttributeType => (
            <tr key={workAttributeType.gid}>
              <th />
              <th>
                {lp_attributes(workAttributeType.name, 'work_attribute_type')}
              </th>
              <td>{fc('work.attribute.' + workAttributeType.id)}</td>
              <td>{fp('work.attribute.' + workAttributeType.id, 'work')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('work.attribute.null')}</td>
            <td>{fp('work.attribute.null', 'work')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Areas')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Areas'))}</th>
            <td>{fc('area')}</td>
            <td />
          </tr>
          {areaTypes.map(areaType => (
            <tr key={areaType.gid}>
              <th />
              <th>{lp_attributes(areaType.name, 'area_type')}</th>
              <td>{fc('area.type.' + areaType.id)}</td>
              <td>{fp('area.type.' + areaType.id, 'area')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('area.type.null')}</td>
            <td>{fp('area.type.null', 'area')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Places')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Places'))}</th>
            <td>{fc('place')}</td>
            <td />
          </tr>
          {placeTypes.map(placeType => (
            <tr key={placeType.gid}>
              <th />
              <th>{lp_attributes(placeType.name, 'place_type')}</th>
              <td>{fc('place.type.' + placeType.id)}</td>
              <td>{fp('place.type.' + placeType.id, 'place')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('place.type.null')}</td>
            <td>{fp('place.type.null', 'place')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{lp_statistics('Series', 'plural')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">
              {addColonText(lp_statistics('Series', 'plural'))}
            </th>
            <td>{fc('series')}</td>
            <td />
          </tr>
          {seriesTypes.map(seriesType => (
            <tr key={seriesType.gid}>
              <th />
              <th>{lp_attributes(seriesType.name, 'series_type')}</th>
              <td>{fc('series.type.' + seriesType.id)}</td>
              <td>{fp('series.type.' + seriesType.id, 'series')}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>{l_statistics('Instruments')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l_statistics('Instruments'))}</th>
            <td>{fc('instrument')}</td>
            <td />
          </tr>
          {instrumentTypes.map(instrumentType => (
            <tr key={instrumentType.gid}>
              <th />
              <th>{lp_attributes(instrumentType.name, 'instrument_type')}</th>
              <td>{fc('instrument.type.' + instrumentType.id)}</td>
              <td>
                {fp('instrument.type.' + instrumentType.id, 'instrument')}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('instrument.type.null')}</td>
            <td>{fp('instrument.type.null', 'instrument')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Events')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(('Events'))}</th>
            <td>{fc('event')}</td>
            <td />
          </tr>
          {eventTypes.map(eventType => (
            <tr key={eventType.gid}>
              <th />
              <th>{lp_attributes(eventType.name, 'event_type')}</th>
              <td>{fc('event.type.' + eventType.id)}</td>
              <td>{fp('event.type.' + eventType.id, 'event')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{fc('event.type.null')}</td>
            <td>{fp('event.type.null', 'event')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Collections')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Collections')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l_statistics('Collections'))}</th>
            <td>{fc('collection')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of releases'))}</th>
            <td>{fc('collection.type.release.all')}</td>
            <td>{fp('collection.type.release.all', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Generic'))}</th>
            <td>{fc('collection.type.release')}</td>
            <td>
              {fp('collection.type.release', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Owned music'))}</th>
            <td>{fc('collection.type.owned')}</td>
            <td>
              {fp('collection.type.owned', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Wishlist'))}</th>
            <td>{fc('collection.type.wishlist')}</td>
            <td>
              {fp('collection.type.wishlist', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of events'))}</th>
            <td>{fc('collection.type.event.all')}</td>
            <td>{fp('collection.type.event.all', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Generic'))}</th>
            <td>{fc('collection.type.event')}</td>
            <td>
              {fp('collection.type.event', 'collection.type.event.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Of type Attending'))}</th>
            <td>{fc('collection.type.attending')}</td>
            <td>
              {fp('collection.type.attending', 'collection.type.event.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l_statistics('Of type Maybe attending'))}</th>
            <td>{fc('collection.type.maybe_attending')}</td>
            <td>
              {fp(
                'collection.type.maybe_attending',
                'collection.type.event.all',
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of areas'))}</th>
            <td>{fc('collection.type.area')}</td>
            <td>{fp('collection.type.area', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of artists'))}</th>
            <td>{fc('collection.type.artist')}</td>
            <td>{fp('collection.type.artist', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('Of instruments'))}
            </th>
            <td>{fc('collection.type.instrument')}</td>
            <td>{fp('collection.type.instrument', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of labels'))}</th>
            <td>{fc('collection.type.label')}</td>
            <td>{fp('collection.type.label', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of places'))}</th>
            <td>{fc('collection.type.place')}</td>
            <td>{fp('collection.type.place', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of recordings'))}</th>
            <td>{fc('collection.type.recording')}</td>
            <td>{fp('collection.type.recording', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('Of release groups'))}
            </th>
            <td>{fc('collection.type.release_group')}</td>
            <td>{fp('collection.type.release_group', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of series'))}</th>
            <td>{fc('collection.type.series')}</td>
            <td>{fp('collection.type.series', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Of works'))}</th>
            <td>{fc('collection.type.work')}</td>
            <td>{fp('collection.type.work', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Public'))}</th>
            <td>{fc('collection.public')}</td>
            <td>{fp('collection.public', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l_statistics('Private'))}</th>
            <td>{fc('collection.private')}</td>
            <td>{fp('collection.private', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {addColonText(l_statistics('With collaborators'))}
            </th>
            <td>{fc('collection.has_collaborators')}</td>
            <td>{fp('collection.has_collaborators', 'collection')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Editors, Edits, and Votes')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Editors')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Editors (valid):')}</th>
            <td>{fc('editor.valid')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('active ever:')}</th>
            <td>{fc('editor.valid.active')}</td>
            <td>{fp('editor.valid.active', 'editor.valid')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l_statistics('who edited and/or voted in the last 7 days:')}
            </th>
            <td>{fc('editor.activelastweek')}</td>
            <td>{fp('editor.activelastweek', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l_statistics('who edited in the last 7 days:')}</th>
            <td>{fc('editor.editlastweek')}</td>
            <td>{fp('editor.editlastweek', 'editor.activelastweek')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l_statistics('who voted in the last 7 days:')}</th>
            <td>{fc('editor.votelastweek')}</td>
            <td>{fp('editor.votelastweek', 'editor.activelastweek')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who edit:')}</th>
            <td>{fc('editor.valid.active.edits')}</td>
            <td>{fp('editor.valid.active.edits', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who vote:')}</th>
            <td>{fc('editor.valid.active.votes')}</td>
            <td>{fp('editor.valid.active.votes', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who leave edit notes:')}</th>
            <td>{fc('editor.valid.active.notes')}</td>
            <td>{fp('editor.valid.active.notes', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {lp_statistics('who use tags:', 'folksonomy')}
            </th>
            <td>{fc('editor.valid.active.tags')}</td>
            <td>{fp('editor.valid.active.tags', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use ratings:')}</th>
            <td>{fc('editor.valid.active.ratings')}</td>
            <td>
              {fp('editor.valid.active.ratings', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use subscriptions:')}</th>
            <td>{fc('editor.valid.active.subscriptions')}</td>
            <td>
              {fp('editor.valid.active.subscriptions', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use collections:')}</th>
            <td>{fc('editor.valid.active.collections')}</td>
            <td>
              {fp('editor.valid.active.collections', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l_statistics('who have registered applications:')}
            </th>
            <td>{fc('editor.valid.active.applications')}</td>
            <td>
              {fp('editor.valid.active.applications', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('validated email only:')}</th>
            <td>{fc('editor.valid.validated_only')}</td>
            <td>{fp('editor.valid.validated_only', 'editor.valid')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('inactive:')}</th>
            <td>{fc('editor.valid.inactive')}</td>
            <td>{fp('editor.valid.inactive', 'editor.valid')}</td>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Editors (deleted):')}</th>
            <td>{fc('editor.deleted')}</td>
            <td />
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Edits')}</th>
          </tr>
          <tr>
            <th colSpan="4">{addColonText(l_statistics('Edits'))}</th>
            <td>{fc('edit')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(l_statistics('Open'))}</th>
            <td>{fc('edit.open')}</td>
            <td>{fp('edit.open', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(l_statistics('Applied'))}</th>
            <td>{fc('edit.applied')}</td>
            <td>{fp('edit.applied', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(l_statistics('Voted down'))}</th>
            <td>{fc('edit.failedvote')}</td>
            <td>{fp('edit.failedvote', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (dependency):')}</th>
            <td>{fc('edit.faileddep')}</td>
            <td>{fp('edit.faileddep', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (prerequisite):')}</th>
            <td>{fc('edit.failedprereq')}</td>
            <td>{fp('edit.failedprereq', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (internal error):')}</th>
            <td>{fc('edit.error')}</td>
            <td>{fp('edit.error', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">
              {addColonText(lp_statistics('Cancelled', 'edit'))}
            </th>
            <td>{fc('edit.deleted')}</td>
            <td>{fp('edit.deleted', 'edit')}</td>
          </tr>
          <tr>
            <th colSpan="4">{addColonText(l_statistics('Edits'))}</th>
            <td>{fc('edit')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Last 7 days:')}</th>
            <td>{fc('edit.perweek')}</td>
            <td>{fp('edit.perweek', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2" />
            <th>{l_statistics('Yesterday:')}</th>
            <td>{fc('edit.perday')}</td>
            <td>{fp('edit.perday', 'edit.perweek')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Votes')}</th>
          </tr>
          <tr>
            <th colSpan="4">{addColonText(l_statistics('Votes'))}</th>
            <td>{fc('vote')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">
              {addColonText(lp_statistics('Approve', 'vote'))}
            </th>
            <td>{fc('vote.approve')}</td>
            <td>{fp('vote.approve', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp_statistics('Yes', 'vote'))}</th>
            <td>{fc('vote.yes')}</td>
            <td>{fp('vote.yes', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp_statistics('No', 'vote'))}</th>
            <td>{fc('vote.no')}</td>
            <td>{fp('vote.no', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">
              {addColonText(lp_statistics('Abstain', 'vote'))}
            </th>
            <td>{fc('vote.abstain')}</td>
            <td>{fp('vote.abstain', 'vote')}</td>
          </tr>
          <tr>
            <th colSpan="4">{addColonText(l_statistics('Votes'))}</th>
            <td>{fc('vote')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Last 7 days:')}</th>
            <td>{fc('vote.perweek')}</td>
            <td>{fp('vote.perweek', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('Yesterday:')}</th>
            <td>{fc('vote.perday')}</td>
            <td>{fp('vote.perday', 'vote.perweek')}</td>
          </tr>
        </tbody>
      </table>
    </StatisticsLayout>
  );
};

export default Index;
